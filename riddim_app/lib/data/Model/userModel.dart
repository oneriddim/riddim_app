class User {
  String _userid;
  String _username;
  String _fullname;
  String _email;
  String _contact;
  String _token;
  String _dob;
  String _address;
  String _gender;

  String _tickets;
  String _distance;
  String _rating;
  String _hours;

  String _base;
  String _farekm;
  String _faremin;
  String _earn;


  User(this._userid,
      this._username,
      this._fullname,
      this._email,
      this._contact,
      this._token,
      this._dob,
      this._address,
      this._gender,
      this._tickets,
      this._hours,
      this._distance,
      this._rating,
      this._base,
      this._farekm,
      this._faremin,
      this._earn);

  User.map(dynamic obj) {
    this._userid = obj["user_id"];
    this._username = obj["username"];
    this._fullname = obj["fullname"];
    this._email = obj["email"];
    this._contact = obj["contact"];
    this._token = obj["token"];
    this._dob = obj["dob"];
    this._address = obj["address"];
    this._gender = obj["gender"];
    this._tickets = obj["tickets"];
    this._hours = obj["hours"];
    this._distance = obj["distance"];
    this._rating = obj["rating"];
    this._base = obj["base"];
    this._farekm = obj["farekm"];
    this._faremin = obj["faremin"];
    this._earn = obj["earn"];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["user_id"] = _userid;
    map["username"] = _username;
    map["fullname"] = _fullname;
    map["email"] = _email;
    map["contact"] = _contact;
    map["token"] = _token;
    map["dob"] = _dob;
    map["address"] = _address;
    map["gender"] = _gender;


    map["tickets"] = _tickets;
    map["hours"] = _hours;
    map["distance"] = _distance;
    map["rating"] = _rating;
    map["base"] = _base;
    map["farekm"] = _farekm;
    map["faremin"] = _faremin;
    map["earn"] = _earn;

    return map;
  }

  String get userid => _userid;
  String get username => _username;
  String get fullname => _fullname;
  String get email => _email;
  String get contact => _contact;
  String get token => _token;
  String get dob => _dob;
  String get address => _address;
  String get gender => _gender;

  String get tickets => _tickets;
  String get hours => _hours;
  String get distance => _distance;

  String get rating => _rating;

  String get base => _base;
  String get farekm => _farekm;
  String get faremin => _faremin;
  String get earn => _earn;

  set fullname(String value) {
    _fullname = value;
  }

  set email(String value) {
    _email = value;
  }

  set contact(String value) {
    _contact = value;
    _username = value;
  }

  set token(String value) {
    _token = value;
  }

  set dob(String value) {
    _dob = value;
  }

  set address(String value) {
    _address = value;
  }

  set gender(String value) {
    _gender = value;
  }

  set tickets(String value) {
    _tickets = value;
  }


  set earn(String value) {
    _earn = value;
  }


  set faremin(String value) {
    _faremin = value;
  }


  set farekm(String value) {
    _farekm = value;
  }


  set base(String value) {
    _base = value;
  }


  set hours(String value) {
    _hours = value;
  }


  set rating(String value) {
    _rating = value;
  }

  set distance(String value) {
    _distance = value;
  }
}