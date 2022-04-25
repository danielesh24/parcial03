import 'dart:convert';

import 'package:fluteeapps/modelos/photos.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(WebFlutter());
}

class WebFlutter extends StatefulWidget {
  @override
  State<WebFlutter> createState() => _WebFlutterState();
}

class _WebFlutterState extends State<WebFlutter> {
  late Future<List<Photos>> _listadoPhotos;

  Future<List<Photos>> _getPhotos() async {
    final response = await http.get(Uri.parse(
        "https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic"));
    String cuerpo;
    List<Photos> lista = [];
    if (response.statusCode == 200) {
      cuerpo = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(cuerpo);
      print(jsonData);
      for (var item in jsonData["drinks"]) {
        lista.add(Photos(item["strDrink"], item["strDrinkThumb"]));
      }
    } else {
      throw Exception("Falla en conexion  estado 500");
    }
    print(lista);
    return lista;
  }

  @override
  void initState() {
    super.initState();
    _listadoPhotos = _getPhotos();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = FutureBuilder(
      future: _listadoPhotos,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView(
            children: _listadoPhoto(snapshot.data),
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Text("Error");
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consumo Webservice',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(237, 28, 4, 245),
          title: Text('Welcome to TheCocktailDB'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.shopping_bag_outlined),
              onPressed: () {},
            ),
          ],
        ),
        body: futureBuilder,
      ),
    );
  }

  List<Widget> _listadoPhoto(data) {
    List<Widget> photo = [
      TextFormField(
        decoration: InputDecoration(
            iconColor: Color.fromARGB(255, 75, 3, 104),
            icon: Icon(Icons.search),
            labelText: "Busqueda",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )),
      )
    ];
    for (var itempk in data) {
      photo.add(Card(
        elevation: 2.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            //Text(itempk.strDrink),
            Container(
              padding: EdgeInsets.all(2.0),
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    itempk.strDrinkThumb,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Text(
                itempk.strDrink,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ));
    }
    return photo;
  }
}
