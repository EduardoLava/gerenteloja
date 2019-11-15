import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:gerenteloja/blocs/user_bloc.dart';
import 'package:gerenteloja/tabs/users_tab.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  PageController _pageController;
  int _page = 0;
  UserBloc _userBloc;


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _userBloc = UserBloc();
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(// altera o tema somente para os filhos
          canvasColor: Colors.pinkAccent,
          primaryColor: Colors.white,
          textTheme: Theme.of(context).textTheme.copyWith(
            caption: TextStyle(color: Colors.white54)
          )
        ),
        child: BottomNavigationBar(
          currentIndex: _page,
          onTap: (paginaClicada){
            _pageController.animateToPage(
                paginaClicada,
                duration: Duration(microseconds: 500),
                curve: Curves.ease
            );
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text("Clientes")
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              title: Text("Pedidos")
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text("Prodotos")
            )
          ]
        ),
      ),
      body: SafeArea(
        child: BlocProvider<UserBloc>(
          bloc: _userBloc,
          child: PageView(
            controller: _pageController,
            onPageChanged: (pageinaAtual){
              setState(() {// neste caso é indicado, pois refaz a tela toda
                _page = pageinaAtual;
              });
            },
            children: <Widget>[
              UsersTab(),
              Container(color: Colors.yellow,),
              Container(color: Colors.green,),
            ],
          ),
        ),
      ),
    );
  }
}