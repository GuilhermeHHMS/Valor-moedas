import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;


void main(){
  menu();
}

//MENU BÁSICO DE DIRECIONAMENTO.
menu(){
  print('############################################# Selecione a opção: #############################################\n [1] - Ver a cotação de hoje\n [2] - Resgistrar cotação\n [3] - Ver cotações regstradas');

  String opt = stdin.readLineSync().toString();

  switch(int.parse(opt.toUpperCase())){

    case 1:
      today();
      break;
    case 2:
      writeFile();
      break;
    case 3:
      savedFile();
      break;

    default:
      throw('Opção inválida.');


  }
}
//FUNÇÃO DEFINIDA PARA ADQUIRIR A COTAÇÃO DE HOJE, SOLICITANDO OS DADOS DA API.

today() async {
  var data = await getData();

  data.forEach((data){print(data);});

  print('\n\nDeseja salvar este arquivo? [S/N]');
  var choose = stdin.readLineSync().toString().toUpperCase();

  if(choose == 'S'){
    writeFile();
  }
  else{
    return null;
  }
}
//FUNÇÃO DEFINIDA PARA INSERIR OS DADOS SALVOS EM UM DOCUMENTO .TXT.
writeFile() async {
  var data = await getData();
  dynamic read = readFile();

  Directory dir = Directory.current;
  File file = File(dir.path + '/cota.txt');
//QUANDO NÃO TEM UM DOCUMENTO .TXT NESTE DIRETÓRIO, O CODIGO AUTOMATICAMENTE CRIA UM.

  RandomAccessFile raf = file.openSync(mode: FileMode.write);

  if(read.length <= 0){
    raf.writeStringSync(jsonEncode([]));
    return null;
  }

  read = (read != null && read.length >= 0? jsonDecode(read) : 0);


  read.add(data);

  raf.writeString(jsonEncode([] + read));

}

readFile(){
  Directory dir = Directory.current;
  File file = File(dir.path + '/cota.txt');

  return file.readAsStringSync();
}
//ESTA FUNÇÃO EXIBE OS DADOS REGISTRADOS.
savedFile(){
  dynamic fileText = readFile();

  fileText = json.decode(fileText);

  fileText.forEach((file) => print('$fileText \n\n'));

  print('pressione qualquer tecla para continuar...');
  var pause = stdin.readLineSync();
}


//ESTA É A FUNÇÃO RAIZ, QUE ADQUIRE TODOS OS DADOS DA API PELO URL.
Future getData() async{

  String url = 'https://api.hgbrasil.com/finance?key=ebda234c';
  http.Response response = await http.get(Uri.parse(url));

  var cota = jsonDecode(response.body)['results']['currencies'];

  var usd = cota['USD'];
  var eur = cota['EUR'];
  var cad = cota['CAD'];
  var jpy = cota['JPY'];

  Map time = {};
  time['date'] = getTime();

  List<Map> mapas = [

    time,

    {'moeda' : usd['name'],
    'preço' : usd['buy']},

    {'moeda' : eur['name'],
    'preço' : eur['buy']},

    {'moeda' : cad['name'],
    'preço' : cad['buy']},

    {'moeda' : jpy['name'],
    'preço' : jpy['buy']},

  ];

  return mapas;
}
getTime() {
  var time = DateTime.now();
  return time.toString();
}
