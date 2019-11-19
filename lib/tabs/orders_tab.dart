import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerenteloja/blocs/orders_bloc.dart';
import 'package:gerenteloja/widgets/order_tile.dart';

class OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final OrdersBloc _ordersBloc = BlocProvider.of<OrdersBloc>(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: StreamBuilder<List>(
        stream: _ordersBloc.outOrder,
        builder: (context, snapshot) {

          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
              ),
            );
          }

          if(snapshot.data.length == 0){
            return Center(
              child: Text("Nenhum pedido encontrado", style: TextStyle(color: Colors.pinkAccent),),
            );
          }

          return ListView.builder(
              itemBuilder: (context, index){
                return OrderTile(snapshot.data[index]);
              },
            itemCount: snapshot.data.length,
          );
        }
      ),
    );
  }
}
