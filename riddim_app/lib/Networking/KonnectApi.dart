import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:riddim_app/config.dart';

abstract class KonnectApi {
  static final Dio _httpClient = Dio();

  final JsonDecoder _decoder = new JsonDecoder();

  void _setupInterceptor() {
    _httpClient.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options) => requestInterceptor(options),
        onResponse: (Response response) => responseInterceptor(response),
        onError: (DioError dioError) => errorInterceptor(dioError))
    );
  }

  dynamic requestInterceptor(RequestOptions options) async {
    print(
        "--> ${options.method != null ? options.method.toUpperCase() : 'METHOD'} ${"" + (options.baseUrl ?? "") + (options.path ?? "")}");
    print("Headers:");
    options.headers.forEach((k, v) => print('$k: $v'));
    if (options.queryParameters != null) {
      print("queryParameters:");
      options.queryParameters.forEach((k, v) => print('$k: $v'));
    }
    if (options.data != null) {
      print("Body: ${options.data}");
    }
    print(
        "--> END ${options.method != null ? options.method.toUpperCase() : 'METHOD'}");

    return options;
  }

  dynamic responseInterceptor(Response response) async {
    print(
        "<-- ${response.statusCode} ${(response.request != null ? (response.request.baseUrl + response.request.path) : 'URL')}");
    print("Headers:");
    response.headers?.forEach((k, v) => print('$k: $v'));
    print("Response: ${response.data}");
    print("<-- END HTTP");
  }

  dynamic errorInterceptor(DioError dioError) {
    print(
        "<-- ${dioError.message} ${(dioError.response?.request != null ? (dioError.response.request.baseUrl + dioError.response.request.path) : 'URL')}");
    print(
        "${dioError.response != null ? dioError.response.data : 'Unknown Error'}");
    print("<-- End error");
  }

  Future<dynamic> post({
    @required String url,
    Map<String, dynamic> data,
  }) async {
    try {
      final response = await _httpClient.post(
        url,
        data: FormData.fromMap(data),
      );

      return _decoder.convert(response.data);
    } on DioError catch (error) {
      return {
        "error": error.response.statusCode,
        "message" : error.toString()
      };
    } catch (error) {
      return  {
        "error": 500,
        "message" : error.toString()
      };
    }
  }

  Future<dynamic> get({
    @required String url,
  }) async {
    try {
      final response = await _httpClient.get(
        url,
      );

      return _decoder.convert(response.data);
    } on DioError catch (error) {
      return {
        "error": error.response.statusCode,
        "message" : error.toString()
      };
    } catch (error) {
      return  {
        "error": 500,
        "message" : error.toString()
      };
    }
  }
}

class KonnectApiClient extends KonnectApi {
  Future<User> login(String username, String password) async {
    //this._setupInterceptor();
    return post(
        url: Config.loginUrl,
        data:{
          "username": username,
          "password": password,
          "app": 0
        }).then((dynamic res) {
          print(res.toString());
          // ignore: unnecessary_statements
          if(!res["success"]) throw new Exception(res["message"]);
          return new User.map(res["user"]);
    });
  }

  Future<bool> logout(String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.logoutUrl,
        data:{
          "id": token
        }).then((dynamic res) {
          print(res.toString());
          // ignore: unnecessary_statements
          return res["success"];
    });
  }

  Future<User> register(String name, String username, String password) async {
    //this._setupInterceptor();
    return post(
        url: Config.registerUrl,
        data:{
          "name": name,
          "username": username,
          "password": password,
          "app": 0
        }).then((dynamic res) {
      print(res.toString());
      // ignore: unnecessary_statements
      if(!res["success"]) throw new Exception(res["message"]);
      return new User.map(res["user"]);
    });
  }

  Future<bool> updateMyLocation(String token, double lat, double long) async {
    //this._setupInterceptor();
    return post(
        url: Config.updateMyLocationUrl,
        data:{
          "id": token,
          "lat": lat,
          "lng": long
        }).then((dynamic res) {
      print(res.toString());
      return res["success"];
    });
  }

  Future<List> getNearbyUsers(String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.getNearbyUsersUrl,
        data:{
          "id": token
        }).then((dynamic res) {
      print(res.toString());
      // ignore: unnecessary_statements
      if(!res["success"]) throw new Exception(res["message"]);
      return res["data"];
    });
  }

  Future<Map> getMyLocation(String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.getMyLocationUrl,
        data: {
          "id": token,
        }).then((dynamic res) {
      print(res.toString());
      return res;
    });
  }

  Future<List> getCompletedTickets(String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.ticketsCompletedUrl,
        data:{
          "user": token
        }).then((dynamic res) {
      print(res.toString());
      // ignore: unnecessary_statements
      //if(!res["success"]) throw new Exception(res["message"]);
      return res["data"];
    });
  }

  Future<List> getUpcomingTickets(String token, String date) async {
    //this._setupInterceptor();
    return post(
        url: Config.ticketsUpcomingUrl,
        data:{
          "user": token,
          "date": date
        }).then((dynamic res) {
      print(res.toString());
      // ignore: unnecessary_statements
      //if(!res["success"]) throw new Exception(res["message"]);
      return res["data"];
    });
  }

  Future<Map> ticket(String ticket, String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.ticketUrl,
        data:{
          "id": ticket,
          "user": token,
        }).then((dynamic res) {
      print(res.toString());
      return res;
    });
  }

  Future<Map> addTicket(String token, String date, String pickup, double plat, double plng, String dropoff, double dlat, double dlng, String dist, String dur, String notes, String promo) async {
    //this._setupInterceptor();
    return post(
        url: Config.addTicketUrl,
        data:{
          "user": token,
          "date": date,
          "pickup": pickup,
          "pickuplat": plat,
          "pickuplng": plng,
          "dropff": dropoff,
          "dropfflat": dlat,
          "dropfflng": dlng,
          "distance": dist,
          "duration": dur,
          "notes": notes,
          "promo": promo
        }).then((dynamic res) {
      print(res.toString());
      // ignore: unnecessary_statements
      return res;
    });
  }

  Future<Map> isTicketAccepted(String ticket, String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.isTicketAcceptedUrl,
        data: {
          "id": ticket,
          "user": token,
        }).then((dynamic res) {
      print(res.toString());
      return res;
    });
  }

  Future<bool> confirmTicket(String ticket, String token) async {
    //this._setupInterceptor();
  return post(
      url: Config.confirmTicketUrl,
      data:{
        "id": ticket,
        "user": token,
      }).then((dynamic res) {
    print(res.toString());
    return res["success"];
  });
  }

  Future<Map> trackerDriver(String ticket, String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.trackDriverUrl,
        data:{
          "id": ticket,
          "user": token,
        }).then((dynamic res) {
      print(res.toString());
      return res;
    });
  }

  Future<bool> dropoffTicket(String ticket, String token, String lat, String lng) async {
    //this._setupInterceptor();
    return post(
        url: Config.dropoffTicketUrl,
        data:{
          "id": ticket,
          "user": token,
          "lat": lat,
          "lng": lng,
        }).then((dynamic res) {
      print(res.toString());
      return res["success"];
    });
  }

  Future<bool> saveTicketReview(String ticket, String token, String review, double rating) async {
    //this._setupInterceptor();
    return post(
        url: Config.saveTicketReviewUrl,
        data:{
          "id": ticket,
          "user": token,
          "review": review,
          "rating": rating,
        }).then((dynamic res) {
      print(res.toString());
      return res["success"];
    });
  }

  Future<bool> cancelTicket(String ticket, String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.cancelTicketUrl,
        data:{
          "id": ticket,
          "user": token,
        }).then((dynamic res) {
      print(res.toString());
      return res["success"];
    });
  }

  Future<bool> saveProfile(String token, String name, String contact, String email, String gender, String dob, String address, String image) async {
    //this._setupInterceptor();
    return post(
        url: Config.saveProfileUrl,
        data:{
          "id": token,
          "name": name,
          "contact": contact,
          "email": email,
          "gender": gender,
          "dob": dob,
          "address": address,
          "image": image,
        }).then((dynamic res) {
      print(res.toString());
      return res["success"];
    });
  }

  Future<List> getReviews(String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.ticketReviewsUrl,
        data:{
          "user": token
        }).then((dynamic res) {
      print(res.toString());
      // ignore: unnecessary_statements
      //if(!res["success"]) throw new Exception(res["message"]);
      return res["data"];
    });
  }

  Future<List> getPaymentCards(String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.cardsUrl,
        data:{
          "user": token
        }).then((dynamic res) {
      print(res.toString());
      // ignore: unnecessary_statements
      //if(!res["success"]) throw new Exception(res["message"]);
      return res["data"];
    });
  }

  Future<Map> card(String card, String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.cardUrl,
        data:{
          "id": card,
          "user": token,
        }).then((dynamic res) {
      print(res.toString());
      return res;
    });
  }

  Future<bool> saveCard(String token, String card, String name, String number, String month, String year, String cvv, String def) async {
    //this._setupInterceptor();
    return post(
        url: Config.saveCardUrl,
        data:{
          "user": token,
          "id": card,
          "name": name,
          "number": number,
          "month": month,
          "year": year,
          "cvv": cvv,
          "default": def
        }).then((dynamic res) {
      print(res.toString());
      return res["success"];
    });
  }

  Future<bool> deleteCard(String token, String card) async {
    //this._setupInterceptor();
    return post(
        url: Config.deleteCardUrl,
        data:{
          "user": token,
          "id": card
        }).then((dynamic res) {
      print(res.toString());
      return res["success"];
    });
  }

  Future<Map> saveVoucher(String token, String id, String voucher) async {
    //this._setupInterceptor();
    return post(
        url: Config.saveVoucherUrl,
        data:{
          "user": token,
          "voucher": voucher,
          "id": id,
        }).then((dynamic res) {
      print(res.toString());
      return res;
    });
  }

  Future<List> getVouchers(String token) async {
    this._setupInterceptor();
    return post(
        url: Config.vouchersUrl,
        data:{
          "user": token
        }).then((dynamic res) {
      print(res.toString());
      // ignore: unnecessary_statements
      //if(!res["success"]) throw new Exception(res["message"]);
      return res["data"];
    });
  }

  Future<Map> voucher(String card, String token) async {
    //this._setupInterceptor();
    return post(
        url: Config.voucherUrl,
        data:{
          "id": card,
          "user": token,
        }).then((dynamic res) {
      print(res.toString());
      return res;
    });
  }

  Future<bool> deleteVoucher(String token, String card) async {
    //this._setupInterceptor();
    return post(
        url: Config.deleteVoucherUrl,
        data:{
          "user": token,
          "id": card
        }).then((dynamic res) {
      print(res.toString());
      return res["success"];
    });
  }
}
