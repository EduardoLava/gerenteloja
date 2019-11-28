import 'dart:async';
import 'dart:io';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc extends BlocBase {

  final _titleController = BehaviorSubject<String>();
  final _imageController = BehaviorSubject();
  final _deleteControler = BehaviorSubject<bool>();

  Stream<bool> get submitValue => Observable.combineLatest2(
    outImage,
    outTitle,
    (a, b) => true
  );

  Stream<String> get outTitle => _titleController.stream.transform(
    StreamTransformer<String, String>.fromHandlers(
      handleData: (title, sink){
        if(title.isEmpty){
          sink.addError("Insira um titulo");
        }else {
          sink.add(title);
        }
      }
    )
  );
  Stream get outImage => _imageController.stream;
  Stream<bool> get outDelete => _deleteControler.stream;

  DocumentSnapshot category;
  File image;
  String title;

  CategoryBloc(this.category){
    if(this.category != null){
      title = category.data["title"];
      _titleController.add(category.data["title"]);
      _imageController.add(category.data["icon"]);
      _deleteControler.add(true);
    }else {
      _deleteControler.add(false);
    }
  }

  void setTitle(String title){
    this.title = title;
    _titleController.add(title);
  }

  void setImage(File image){
    this.image = image;
    _imageController.add(image);
  }

  @override
  void dispose() {
    _titleController.close();
    _imageController.close();
    _deleteControler.close();
  }

  Future saveData() async {
    if(image == null && category != null && title == category.data["title"]){
      return;
    }

    Map<String, dynamic> dataToUpdate = {};
    if(image != null){
      StorageUploadTask task = FirebaseStorage.instance.ref().child("icons")
          .child(title).putFile(image);

      StorageTaskSnapshot snapshot = await task.onComplete;
      dataToUpdate["icon"] = await snapshot.ref.getDownloadURL();
    }

    if(category == null || title != category.data["title"]){
      dataToUpdate["title"] = title;
    }

    if(category == null){
      await Firestore.instance.collection("products")
          .document(title.toLowerCase())
          .setData(dataToUpdate);
    } else {
      await category.reference.updateData(dataToUpdate);
    }
  }

  void delete(){
    category.reference.delete();
  }

}