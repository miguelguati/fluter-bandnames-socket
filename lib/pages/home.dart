import 'dart:io';

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    // Band(id: '1', name: 'Hillsong', votes: 5),
    // Band(id: '2', name: 'Jesus Culture', votes: 4),
    // Band(id: '3', name: 'Elevation Worship', votes: 3),
    // Band(id: '4', name: 'Cris Tomlin', votes: 4),
  ];

  @override
  void initState() {
    // TODO: implement initState
    final _socketService = Provider.of<SocketService>(context, listen: false);

    _socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload){
    this.bands = ( payload as List).map((banda)=> Band.fromMap(banda)).toList();
     setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    final _socketService = Provider.of<SocketService>(context, listen: false);
    _socketService.socket.off('active-bands');
  }

  @override
  Widget build(BuildContext context) {

    final _socketService = Provider.of<SocketService>(context);
    

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Center(
          child: Text('BandName', style: TextStyle(color: Colors.black87),)
          ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right:10),
            child: _socketService.serverStatus == ServerStatus.Online? Icon(Icons.check_circle, color:Colors.blue):Icon(Icons.offline_bolt, color:Colors.red),
          )
        ],
      ),
      body:  Column(
        children: <Widget>[
          _showGraph(),
          Expanded(child: listaAvatars()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed:(){
          addNewBand();
        } 
      ),
    );
  }

  Widget listaAvatars(){
    final _socketService = Provider.of<SocketService>(context, listen: false);

    return ListView.builder(
          itemCount: bands.length,
          itemBuilder: (BuildContext context, int i) {
          return Dismissible(
                key:Key(bands[i].id),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction){
                  //Hacer el delete desde el server
                  _socketService.socket.emit('delete-band',{'id':bands[i].id});
                },
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(bands[i].name.substring(0,2).toUpperCase()),
                    backgroundColor: Colors.blue[300],
                  ),
                  title: Text(bands[i].name.toUpperCase()),
                  trailing: Text('${bands[i].votes}', style: TextStyle(fontSize: 20),),
                  onTap: (){
                    print(bands[i].name);
                    _socketService.socket.emit('vote-band', {'id':bands[i].id});
                  },
                ),
          ) ;
         },
        );
  }

  addNewBand(){

    final textController = new TextEditingController();

    if(Platform.isAndroid){
      return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text('Agregar Banda:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5,
                child: Text('Add', style: TextStyle(color: Colors.blue),),
                onPressed: () => addBandToList(textController.text)
              )
            ],

          );
        }
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: ( _ ){
        return CupertinoAlertDialog(
          title: Text('Agregar Banda:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text)
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            ),
          ],
        );
      }
    );
    
  }

  void addBandToList(String name){
    if(name.length > 1){
      // Podemos agregar
      final _socketService = Provider.of<SocketService>(context, listen: false);
      _socketService.socket.emit('add-band', {'name':name});
    }

    Navigator.pop(context);

  }

  Widget _showGraph() {

    Map<String, double> dataMap = new Map();
    
    //dataMap.putIfAbsent('Flutter', ()=> 5);
    
   bands.forEach((band){
     dataMap.putIfAbsent(band.name,()=> band.votes.toDouble());
   });
    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(dataMap: dataMap),
    );
  }

}