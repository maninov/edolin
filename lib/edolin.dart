import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
class Edolin extends StatelessWidget{
  final String path;
  const Edolin({super.key,this.path=''});
  @override Widget build(BuildContext context)=>MaterialApp(
    theme:ThemeData(useMaterial3:true,textTheme:GoogleFonts.sawarabiGothicTextTheme(Theme.of(context).textTheme)),debugShowCheckedModeBanner:false,
    home:Shortcuts(shortcuts:<LogicalKeySet,Intent>{
      LogicalKeySet(LogicalKeyboardKey.backspace):const BackspaceIntent(),
      LogicalKeySet(LogicalKeyboardKey.escape,LogicalKeyboardKey.less,LogicalKeyboardKey.shift):const TopIntent(),
      LogicalKeySet(LogicalKeyboardKey.escape,LogicalKeyboardKey.greater,LogicalKeyboardKey.shift):const BottomIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyX):const SaveIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyA):const StartIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyE):const EndIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyF):const ForwardIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyB):const BackIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyN):const NextIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyP):const PreviousIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyD):const DeleteIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyV):const PageIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyL):const UpdateIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyK):const KillIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyY):const YankIntent(),
      LogicalKeySet(LogicalKeyboardKey.control,LogicalKeyboardKey.keyT):const SwapIntent(),
      LogicalKeySet(LogicalKeyboardKey.tab):const IndentIntent(),
    },
    child:Edolins(path:path)));
}
class Edolins extends StatefulWidget{
  final EOF='\$';
  bool _killing=false;bool get killing=>_killing;set killing(f)=>_killing=f;
  int line=0,vmin=0,vmax=0;
  List<String>lines=<String>[],stacks=<String>[];
  final String path;
  Edolins({this.path=''});
  @override State<StatefulWidget>createState()=>_Edolin();
  Future<void>openFile()async{await File(path).openRead().map(utf8.decode).transform(const LineSplitter()).forEach((l)=>lines.add(l));lines.add(EOF);}
  void saveFile(){File f=File(path);String content='';for (var l in lines)content+=(0<l.length&&l[l.length-1]==EOF?l.substring(0,l.length-1):'$l\n');f.writeAsString(content);}
}
class _Edolin extends State<Edolins>{
  final FocusNode _focusNode=FocusNode();
  final TextEditingController c=TextEditingController();
  final ScrollController s=ScrollController();
  final ItemScrollController itemScrollController=ItemScrollController();
  final ItemPositionsListener itemPositionsListener=ItemPositionsListener.create();
  @override void initState(){
    super.initState();
    Future(()async{
      await widget.openFile();
      _focusNode.addListener((){if(!_focusNode.hasFocus){_focusNode.requestFocus();}});
      c.text=widget.lines[widget.line];
      c.selection=TextSelection.fromPosition(const TextPosition(offset:0));
      setState((){});
    });
  }
  @override void dispose(){_focusNode.dispose();super.dispose();}
  Widget get vmonitor=>ValueListenableBuilder<Iterable<ItemPosition>>(valueListenable:itemPositionsListener.itemPositions,builder:(context,pos,child){
    if(pos.isNotEmpty){
      widget.vmin=pos.where((ItemPosition p)=>p.itemTrailingEdge>0).reduce((ItemPosition min,ItemPosition p)=>p.itemTrailingEdge<min.itemTrailingEdge?p:min).index;
      widget.vmax=pos.where((ItemPosition p)=>p.itemLeadingEdge<1).reduce((ItemPosition max,ItemPosition p)=>p.itemLeadingEdge>max.itemLeadingEdge?p:max).index;
    }
    return Container();
  });
  void shared_next(){
    String l=widget.lines[widget.line];
    if(!(0<l.length&&l[l.length-1]==widget.EOF)){
      c.text=widget.lines[++widget.line];
      c.selection=TextSelection.fromPosition(const TextPosition(offset:0));
      setState((){
          if(widget.line>widget.vmax){
            int h=widget.line-((widget.vmax-widget.vmin)>>1);
            if(h<widget.lines.length)jump(h);
          }
      });
    }
  }
  void shared_prev(bool f){
    if(0<widget.line){
      c.text=widget.lines[--widget.line];
      c.selection=TextSelection.fromPosition(f?const TextPosition(offset:0):TextPosition(offset:c.text.length));
      setState((){
        if(widget.line<widget.vmin){
          int h=widget.line-((widget.vmax-widget.vmin)>>1);
          if(h>=0)jump(h);else if(widget.line<widget.vmin)jump(0);
        }
      });
    }
  }
  void shared_fb(int col){
    var ut=s.position.viewportDimension;
    var tp=TextPainter(text:TextSpan(text:c.text.substring(0,(col<=c.text.length?col:c.text.length))),textDirection:TextDirection.ltr);
    tp.layout(maxWidth:double.infinity);
    if(tp.width*2.0<s.position.maxScrollExtent){s.jumpTo(((tp.width*2.0)~/ut)*ut);}else{s.jumpTo(s.position.maxScrollExtent);}
    c.selection=TextSelection.fromPosition(TextPosition(offset:col));
  }
  @override Widget build(BuildContext context){
    return Actions(
      actions:<Type,Action<Intent>>{
        SaveIntent:CallbackAction<SaveIntent>(onInvoke:(SaveIntent intent){print("saved");widget.saveFile();}),
        StartIntent:CallbackAction<StartIntent>(onInvoke:(StartIntent intent){widget.killing=false;c.selection=TextSelection.fromPosition(const TextPosition(offset:0));s.jumpTo(s.position.minScrollExtent);}),
        EndIntent:CallbackAction<EndIntent>(onInvoke:(EndIntent intent){widget.killing=false;c.selection=TextSelection.fromPosition(TextPosition(offset:0<c.text.length&&c.text[c.text.length-1]!=widget.EOF?c.text.length:c.text.length-1));s.jumpTo(s.position.maxScrollExtent);}),
        ForwardIntent:CallbackAction<ForwardIntent>(onInvoke:(ForwardIntent intent){widget.killing=false;int column=c.selection.base.offset;if(column<c.text.length){if(c.text[column]==widget.EOF)return;shared_fb(column+1);}else shared_next();}),
        BackIntent:CallbackAction<BackIntent>(onInvoke:(BackIntent intent){widget.killing=false;int column=c.selection.base.offset;if(0<column)shared_fb(column-1);else shared_prev(false);}),
        NextIntent:CallbackAction<NextIntent>(onInvoke:(NextIntent intent){widget.killing=false;shared_next();}),
        PreviousIntent:CallbackAction<PreviousIntent>(onInvoke:(PreviousIntent intent){widget.killing=false;shared_prev(true);}),
        BackspaceIntent:CallbackAction<BackspaceIntent>(onInvoke:(BackspaceIntent intent){
          widget.killing=false;
          int column=c.selection.base.offset;
          if(0<column){
            column--;
            c.text=c.text.substring(0,column)+c.text.substring(column+1);
            c.selection=TextSelection.fromPosition(TextPosition(offset:column));
          }else if(widget.line!=0){
            column=widget.lines[widget.line-1].length;
            c.text=widget.lines[widget.line-1]+=widget.lines[widget.line];
            widget.lines.removeAt(widget.line--);
            c.selection=TextSelection.fromPosition(TextPosition(offset:column));
            setState((){});
          }
        }),
        DeleteIntent:CallbackAction<DeleteIntent>(onInvoke:(DeleteIntent intent){
          widget.killing=false;
          int column=c.selection.base.offset;
          if(column<c.text.length){
            if(c.text[column]==widget.EOF)return;else c.text=c.text.substring(0,column)+c.text.substring(column+1);
          }else{
            widget.lines[widget.line]=c.text;
            widget.lines[widget.line]=c.text+=widget.lines[widget.line+1];
            widget.lines.removeAt(widget.line+1);
            setState((){});
          }
          c.selection=TextSelection.fromPosition(TextPosition(offset:column));
        }),
        TopIntent:CallbackAction<TopIntent>(onInvoke:(TopIntent intent){
          widget.killing=false;
          widget.line=0;
          c.text=widget.lines[0];
          c.selection=TextSelection.fromPosition(const TextPosition(offset:0));
          setState((){jump(0);});
        }),
        BottomIntent:CallbackAction<BottomIntent>(onInvoke:(BottomIntent intent){
          widget.killing=false;
          widget.line=widget.lines.length>1?widget.lines.length-2:0;
          c.text=widget.lines[widget.line];
          c.selection=TextSelection.fromPosition(const TextPosition(offset:0));
          setState((){jump(widget.line);});
        }),
        PageIntent:CallbackAction<PageIntent>(onInvoke:(PageIntent intent){
          widget.killing=false;
          int n=widget.line+(widget.vmax-widget.vmin);
          if(n<widget.lines.length-1){
            widget.line=n;
            c.text=widget.lines[n];
            c.selection=TextSelection.fromPosition(const TextPosition(offset:0));
            setState((){jump(n);});
          }
        }),
        UpdateIntent:CallbackAction<UpdateIntent>(onInvoke:(UpdateIntent intent){
          widget.killing=false;
          c.selection=TextSelection.fromPosition(TextPosition(offset:c.selection.base.offset));
          setState((){
            int n=widget.line-((widget.vmax-widget.vmin)>>1);
            if(0<=n)jump(n);
          });
        }),
        KillIntent:CallbackAction<KillIntent>(onInvoke:(KillIntent intent){
          int column=c.selection.base.offset;
          widget.lines[widget.line]=c.text;
          var str=c.text.substring(column);
          if(0<str.length&&str[str.length-1]==widget.EOF){
            if(str.length==1){widget.killing=false;return;}
            if(!widget.killing)widget.stacks=[];
            widget.stacks.add(str.substring(0,str.length-1));
            widget.killing=false;
            widget.lines[widget.line]=c.text=c.text.substring(0,column)+widget.EOF;
          }else{
            if(!widget.killing)widget.stacks=[];
            widget.stacks.add(str);
            widget.killing=true;
            widget.lines[widget.line]=c.text=c.text.substring(0,column)+widget.lines[widget.line+1];
            widget.lines.removeAt(widget.line+1);
            setState((){});
          }
          c.selection=TextSelection.fromPosition(TextPosition(offset:column));
        }),
        YankIntent:CallbackAction<YankIntent>(onInvoke:(YankIntent intent){
          widget.killing=false;
          int column=c.selection.base.offset;
          widget.lines[widget.line]=c.text;
          if(widget.stacks.isNotEmpty){
            var clone=[...widget.stacks];
            clone[clone.length-1]+=c.text.substring(column);
            widget.lines[widget.line]=c.text=c.text.substring(0,column)+clone[0];
            clone.removeAt(0);
            widget.lines.insertAll(widget.line+1,clone);
            c.selection=TextSelection.fromPosition(TextPosition(offset:column));
            setState((){});
          }
        }),
        SwapIntent:CallbackAction<SwapIntent>(onInvoke:(SwapIntent intent){
          widget.killing=false;
          int column=c.selection.base.offset;
          if(column>1){
            c.text=c.text.substring(0,column-2)+c.text.substring(column-1,column)+c.text.substring(column-2,column-1)+c.text.substring(column);
            c.selection=TextSelection.fromPosition(TextPosition(offset:column));
          }
        }),
        IndentIntent:CallbackAction<IndentIntent>(onInvoke:(IndentIntent intent){
          widget.killing=false;
          int column=c.selection.base.offset;
          c.text=c.text.substring(0,column)+"  "+c.text.substring(column);
          c.selection=TextSelection.fromPosition(TextPosition(offset:column+2));
        })
      },
      child:Builder(builder:(context){
          return Scaffold(
          body:Column(
            children:[
              vmonitor,
              Scrollbar(controller:s,child:TextField(
                  onSubmitted:(s){
                    widget.killing=false;
                    if(s!=widget.lines[widget.line]){
                      widget.lines[widget.line]=s;
                    }else{
                      int column=c.selection.base.offset;
                      widget.lines[widget.line]=s.substring(0,column);
                      widget.lines.insert(++widget.line,s.substring(column));
                    }
                    c.text=widget.lines[widget.line];
                    c.selection=TextSelection.fromPosition(const TextPosition(offset:0));
                    setState((){weakjump(widget.line);});
                  },
                  focusNode:_focusNode,autofocus:true,maxLines:1,controller:c,scrollController:s,style:TextStyle(fontSize:Theme.of(context).primaryTextTheme.bodyText1!.fontSize))),
              Expanded(child:ScrollablePositionedList.builder(itemCount:widget.lines.length,itemBuilder:(context,index)=>item(index),itemScrollController:itemScrollController,itemPositionsListener:itemPositionsListener))
            ]
        ));
      })
    );
  }
  void jump(int i)=>itemScrollController.jumpTo(index:i);
  void weakjump(int i){if(widget.vmin<=widget.line&&widget.line<=widget.vmax)return;jump(i);}
  Widget item(int i)=>Container(decoration:BoxDecoration(color:widget.line==i?Colors.cyan:Colors.white),child:Text(widget.lines[i]));
}
class SaveIntent extends Intent{const SaveIntent();}
class StartIntent extends Intent{const StartIntent();}
class EndIntent extends Intent{const EndIntent();}
class ForwardIntent extends Intent{const ForwardIntent();}
class BackIntent extends Intent{const BackIntent();}
class NextIntent extends Intent{const NextIntent();}
class PreviousIntent extends Intent{const PreviousIntent();}
class BackspaceIntent extends Intent{const BackspaceIntent();}
class DeleteIntent extends Intent{const DeleteIntent();}
class TopIntent extends Intent{const TopIntent();}
class BottomIntent extends Intent{const BottomIntent();}
class PageIntent extends Intent{const PageIntent();}
class UpdateIntent extends Intent{const UpdateIntent();}
class KillIntent extends Intent{const KillIntent();}
class YankIntent extends Intent{const YankIntent();}
class SwapIntent extends Intent{const SwapIntent();}
class IndentIntent extends Intent{const IndentIntent();}
