import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seeds_system/routes.dart';
import '../../blocs/seeds_bloc/seeds_bloc.dart';
import '../../blocs/seeds_bloc/seeds_state.dart';
import '../../blocs/seeds_bloc/seeds_event.dart';
import '../../models/seeds.dart';

class PostSeeds extends StatefulWidget {
  const PostSeeds({Key? key}) : super(key: key);

  @override
  State<PostSeeds> createState() => _PostSeedsState();
}

class _PostSeedsState extends State<PostSeeds> {
  TextEditingController name = TextEditingController();
  TextEditingController manufacturer = TextEditingController();
  TextEditingController manufacturedAt = TextEditingController();
  TextEditingController expiresIn = TextEditingController();

  late final SeedsBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = SeedsBloc();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            alignment: Alignment.centerLeft,
            icon: const Icon(Icons.add_box),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(dashboardRoute);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromRGBO(255, 255, 255, 255).withOpacity(0.5),
              const Color.fromRGBO(0, 140, 49, 1).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0, 1],
          ),
        ),
        child: BlocBuilder<SeedsBloc, SeedsStates>(
            bloc: bloc,
            builder: (context, state) {
              return Column(
                children: <Widget>[
                  TextFormField(
                    controller: name,
                    decoration:
                        const InputDecoration(labelText: "Nome da semente"),
                  ),
                  TextFormField(
                    controller: manufacturer,
                    decoration: const InputDecoration(labelText: "Fabricante"),
                  ),
                  TextFormField(
                    controller: manufacturedAt,
                    decoration:
                        const InputDecoration(labelText: "Data de fabricação"),
                  ),
                  TextFormField(
                    controller: expiresIn,
                    decoration:
                        const InputDecoration(labelText: "Data de validade"),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        bloc.add(RegisterSeedEvent(Seeds(
                            name: name.text,
                            manufacturer: manufacturer.text,
                            manufacturedAt: manufacturedAt.text,
                            expiresIn: expiresIn.text)));
                        Navigator.of(context)
                            .pushReplacementNamed(dashboardRoute);
                      },
                      child: const Text("Salvar"))
                ],
              );
            }),
      ),
    );
  }
}
