import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:seeds_system/database/seeds_database_model.dart';
import 'package:seeds_system/exceptions.dart';
import 'package:seeds_system/ui/widgets/show_dialogs.dart';
import 'package:seeds_system/ui/widgets/show_snackbar.dart';
import '../../../utils/routes.dart';
import '../../../blocs/seeds_bloc/seeds_bloc.dart';
import '../../../blocs/seeds_bloc/seeds_state.dart';
import '../../../blocs/seeds_bloc/seeds_event.dart';

class SeedDetail extends StatefulWidget {
  final SeedsDatabaseModel seed;
  final String name;
  final String manufacturer;
  final String manufacturedAt;
  final String expiresIn;
  const SeedDetail(
      {required this.name,
      required this.manufacturer,
      required this.manufacturedAt,
      required this.expiresIn,
      required this.seed,
      Key? key})
      : super(key: key);

  @override
  State<SeedDetail> createState() => _SeedDetailState();
}

class _SeedDetailState extends State<SeedDetail> {
  TextEditingController nameController = TextEditingController();
  TextEditingController manufacturerController = TextEditingController();
  DateTime? _manufacturedAt;
  DateTime? _expiresIn;
  final applicationDateFormat = DateFormat('dd-MM-yyyy');
  final dateFormat = DateFormat('yyyy-MM-dd');

  void _manufacturedAtDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    ).then((manufacturedAtPickedDate) {
      if (manufacturedAtPickedDate == null) {
        return;
      }
      setState(() {
        _manufacturedAt = manufacturedAtPickedDate;
      });
    });
  }

  void _expiresInDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _manufacturedAt!.add(const Duration(days: 1)),
      firstDate: _manufacturedAt!.add(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 5),
    ).then((expiresInPickedDate) {
      if (expiresInPickedDate == null) {
        return;
      }
      setState(() {
        _expiresIn = expiresInPickedDate;
      });
    });
  }

  late final SeedsBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<SeedsBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      color: Colors.green.shade200,
      child: BlocBuilder<SeedsBloc, SeedsStates>(
          bloc: bloc,
          builder: (context, state) {
            return Column(children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: widget.name),
                    ),
                    TextFormField(
                      controller: manufacturerController,
                      decoration:
                          InputDecoration(labelText: widget.manufacturer),
                    ),
                    SizedBox(
                      height: 70,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _manufacturedAt == null
                                  ? widget.manufacturedAt
                                  : 'Data de Fabricação: ${applicationDateFormat.format(_manufacturedAt!)}',
                            ),
                          ),
                          OutlinedButton(
                            child: const Text(
                              'Insira a data',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _manufacturedAtDatePicker,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 70,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _expiresIn == null
                                  ? widget.expiresIn
                                  : 'Data de vencimento: ${applicationDateFormat.format(_expiresIn!)}',
                            ),
                          ),
                          OutlinedButton(
                            child: const Text(
                              'Insira a data',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _manufacturedAt == null
                                ? null
                                : _expiresInDatePicker,
                          ),
                        ],
                      ),
                    ),
                    BlocListener<SeedsBloc, SeedsStates>(
                      listener: (context, state) async {
                        if (state is SaveSeedsFailureState) {
                          await showErrorDialog(
                              context, state.exception.toString());
                          await Future.delayed(const Duration(seconds: 1));
                          Navigator.of(context)
                              .pushReplacementNamed(dashboardRoute);
                        }
                      },
                      child: ElevatedButton(
                          onPressed: () {
                            bloc.add(UpdateSeedEvent(SeedsDatabaseModel(
                                id: widget.seed.id,
                                name: nameController.text,
                                manufacturer: manufacturerController.text,
                                manufacturedAt: dateFormat
                                    .format(_manufacturedAt!)
                                    .toString(),
                                expiresIn:
                                    dateFormat.format(_expiresIn!).toString(),
                                createdAt: widget.seed.createdAt,
                                createdBy: widget.seed.createdBy,
                                isSync: widget.seed.isSync)));
                            Navigator.of(context)
                                .pushReplacementNamed(dashboardRoute);
                          },
                          child: const Text("Atualizar")),
                    ),
                  ],
                ),
              ),
              Row(children: [
                BlocListener<SeedsBloc, SeedsStates>(
                  listener: (context, state) async {
                    if (state is SyncSeedsFailureState) {
                      if (state.exception is TimeExceeded) {
                        await showErrorDialog(
                            context, 'Tempo excedido. Tente novamente!');
                      } else if (state.exception is UnavailableServer) {
                        await showErrorDialog(context,
                            'Servidor indisponível, tente novament mais tarde');
                      }
                    } else if (state is SyncSeedsSuccessState) {
                      Navigator.of(context)
                          .pushReplacementNamed(dashboardRoute);
                    }
                  },
                  child: SizedBox(
                    width: screenSize.width * 0.5,
                    child: ElevatedButton(
                        onPressed: () {
                          bloc.add(SyncSeedEvent(widget.seed));
                        },
                        child: const Text("Sincronizar")),
                  ),
                ),
                BlocListener<SeedsBloc, SeedsStates>(
                  listener: (context, state) async {
                    if (state is DeleteSeedsFailureState) {
                      await showErrorDialog(
                          context, state.exception.toString());
                      await Future.delayed(const Duration(seconds: 1));
                      Navigator.of(context)
                          .pushReplacementNamed(dashboardRoute);
                    } else {
                      Navigator.of(context)
                          .pushReplacementNamed(dashboardRoute);
                    }
                  },
                  child: SizedBox(
                    width: screenSize.width * 0.5,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                        onPressed: () {
                          bloc.add(DeleteSeedEvent(widget.seed));
                        },
                        child: const Text("Deletar")),
                  ),
                ),
              ]),
            ]);
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
