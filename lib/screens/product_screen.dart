import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gerenteloja/blocs/products_bloc.dart';
import 'package:gerenteloja/validators/product_validator.dart';
import 'package:gerenteloja/widgets/images_widget.dart';

class ProductScreen extends StatefulWidget {

  final String categoryId;
  final DocumentSnapshot product;



  ProductScreen({this.categoryId, this.product});


  @override
  _ProductScreenState createState() => _ProductScreenState(categoryId, product);
}

class _ProductScreenState extends State<ProductScreen> with ProductValidator {

  final ProductsBloc _productsBloc;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _ProductScreenState(String categoryId, DocumentSnapshot product) :
    _productsBloc = ProductsBloc(categoryId: categoryId, product: product);

  @override
  Widget build(BuildContext context) {

    InputDecoration _buildDecoration(String label){
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey)
      );
    }

    final _fieldStyle = TextStyle(
        color: Colors.white,
        fontSize: 16
    );


    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        title: StreamBuilder<bool>(
          stream: _productsBloc.outCreated,
          initialData: false,
          builder: (context, snapshot) {
            return Text(snapshot.data ? "Editar produto" : "Criar produto");
          }
        ),
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: _productsBloc.outCreated,
            initialData: false,
            builder: (context, snapshot){
              if(snapshot.data){
                return
                  StreamBuilder<bool>(
                      stream: _productsBloc.outLoading,
                      initialData: false,
                      builder: (context, snapshot) {
                        return IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: snapshot.data ? null : (){
                            _productsBloc.deleteProduct();
                            Navigator.of(context).pop();
                          },
                        );
                      }
                  );
              }

              return Container();
            },
          ),
          StreamBuilder<bool>(
            stream: _productsBloc.outLoading,
            initialData: false,
            builder: (context, snapshot) {
              return IconButton(
                icon: Icon(Icons.save),
                onPressed: snapshot.data ? null : saveProduct ,
              );
            }
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: StreamBuilder<Map>(
              stream: _productsBloc.outData,
              builder: (context, snapshot) {

                if(!snapshot.hasData){
                  return Container();
                }

                return ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    Text(
                      "Imagens",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12
                      ),
                    ),
                    ImagesWidget(
                      context: context,
                        initialValue: snapshot.data["images"],
                        onSaved: _productsBloc.saveImages,
                        validator: validateImages,
                    ),
                    TextFormField(
                      initialValue: snapshot.data["title"],
                      style: _fieldStyle,
                      decoration: _buildDecoration("Título"),
                      onSaved: _productsBloc.saveTitle,
                      validator: validateTitle
                    ),
                    TextFormField(
                      initialValue: snapshot.data["description"],
                      style: _fieldStyle,
                      maxLines: 6,
                      decoration: _buildDecoration("Descrição"),
                      onSaved: _productsBloc.saveDescription,
                      validator: validateDescription
                    ),
                    TextFormField(
                        initialValue: snapshot.data["price"]?.toStringAsFixed(2),
                      style: _fieldStyle,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: _buildDecoration("Preço"),
                      onSaved: _productsBloc.savePrice,
                      validator: validatePrice
                    ),
                  ],
                );
              }
            ),
          ),
          StreamBuilder<bool>(
              stream: _productsBloc.outLoading,
              initialData: false,
              builder: (context, snapshot) {
                return IgnorePointer(
                  ignoring: !snapshot.data,
                  child: Container(color: snapshot.data ? Colors.black54 : Colors.transparent,),
                );
              }
          )
        ],
      ),
    );
  }

  void saveProduct() async {

    if(_formKey.currentState.validate()){
      _formKey.currentState.save();

      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Salvando produto...", style: TextStyle(color: Colors.white),),
          duration: Duration(minutes: 1),
          backgroundColor: Colors.pinkAccent,
        )

      );

      bool success = await _productsBloc.saveProduct();

      _scaffoldKey.currentState.removeCurrentSnackBar();

      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(success ? "Produto salvo" : "Erro ao salvar o produto", style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.pinkAccent,
          )

      );

    }

  }

}
