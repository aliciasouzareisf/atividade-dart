import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'arguments.dart';
import 'exceptions.dart';

class CommandRunner {

CommandRunner ({this.onError});

  final Map<String, Command> _commands = <String, Command>{};

  UnmodifiableSetView<Command> get comands =>
      UnmodifiableSetView<Command>(<Command>{..._commands.values})

      FutureOr<void> Function(Object)? onError;

  Future<void> run(List<String> input) async {
    try{
    final ArgResults results = parse(input);
    if (results.command != null) {
      Object? output = await results.command!.run(results);
      print(output.toString());
    }
    }on Exception catch(exception){
      if (onError != null){
        onError! (exception);
      }else{
        rethrow;
      }
    }
  }

  void addCommand(Command command) {
    // TODO: handle error (Commands can't have names that conflict)
    _commands[command.name] = command;
    command.runner = this;
  }
 
  ArgResults parse(List<String> input) {
    ArgResults results = ArgResults();
    if(input.isEmpty) return results;

    if(_commands.containsKey(input.first)){
      results.command = _commands[input.first];
      input = input.sublist(1);
    }else{
      throw ArgumentException(
        'A primeira palavra da entrada deve ser um comando',
        null,
        input.first,
      );
    }
    //Erro se multiplos comandos for fornecido 
    if(results.command != null
      && input.isNotEmpty
      &&_commands.constainsKey(input.first)){
        throw ArgumentException(
          'Entrada pode conter apenas um comando. $(input.first) e $(results.command!.name) são chamados.',
          null,
          input.first,
        );
      }

      Map<Option, Object?> inputOptions = {};
      int = i = 0;
      while (i <input.length){
        if(input{i}.startswith('-')){
          var base = _removeDash(input[i]);
          var option = results.command!.options.firtsWhere(
            (option) => option.name == base || option.abbr == base,
            orElse: () {
              throw ArgumentsException(
                'Pesquisa ${input[i]} não reconhecida.',
              results.command!.name,
              input[i],
             );
            },
          );

          if (option.type == OptionType.flag){
            inputOptions[option] = true;
            i++;
            continue;
          }
          if (option.type == OptionType.option){
            if(i + 1>= input.length){
              throw ArgumentException(
                'Opção ${option.name} requer um argumento',
                results.command!.name,
                option.name
              );
            }
            if(input[i+1].startsWith('-')){

            }

          }
        }
      }
  }

  // Returns usage for the executable only.
  // Should be overridden if you aren't using [HelpCommand]
  // or another means of printing usage.

  String get usage {
    final exeFile = Platform.script.path.split('/').last;
    return 'Usage: dart bin/$exeFile <command> [commandArg?] [...options?]';
  }
  String _removeDash(String input){
    if(input.startsWith('--')){
      return input.substring(1);
    }
    return input;
  }
}
~