import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Hillsong', votes: 5),
    Band(id: '2', name: 'Jesus Culture', votes: 4),
    Band(id: '3', name: 'Elevation Worship', votes: 3),
    Band(id: '4', name: 'Cris Tomlin', votes: 4),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Center(
          child: Text('BandName', style: TextStyle(color: Colors.black87),)
          ),
        backgroundColor: Colors.white,
      ),
      body:  listaAvatars(),
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
    return ListView.builder(
          itemCount: bands.length,
          itemBuilder: (BuildContext context, int i) {
          return Dismissible(
                key:Key(bands[i].id),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction){
                  print('Direction: $direction');
                  //TODO: Hacer el delete desde el server

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
    print(name);
    if(name.length > 1){
      // Podemos agregara
      this.bands.add(new Band(id:DateTime.now().toString(), name: name, votes: 4 ));
      setState(() {});
    }

    Navigator.pop(context);

  }

}