class LogboekItem {
  final int ID = -1;
  final DateTime DATUM = null;
  final String REG_CALL = null;

  LogboekItem(
    this.ID,
    this.DATUM,
    this.REG_CALL
  )

  factory LogboekItem.fromJson(Map<String, dynamic> parsedJson)
  {
    
  }
}

/*
class Logboek {
  final int recordsInDatabase;
  final List<LogboekItems> vluchten;

  factory Logboek.fromJson(Map<String, dynamic> parsedJson) {
    var streetsFromJson  = parsedJson['streets'];
    //print(streetsFromJson.runtimeType);
    // List<String> streetsList = new List<String>.from(streetsFromJson);
    List<String> streetsList = streetsFromJson.cast<String>();

    return new Logboek(
      recordsInDatabase: parsedJson['total'],
      streets: streetsList,
    );
  }

}
*/