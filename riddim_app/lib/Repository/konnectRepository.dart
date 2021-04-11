import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:riddim_app/Networking/KonnectApi.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/konnectDatasource.dart';

class KonnectRepository {
  KonnectApiClient api = new KonnectApiClient();
  KonnectDatasource db = new KonnectDatasource();

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {

    User user = await api.login(username, password);

    await db.saveUser(user);

    return user.token;
  }

  Future<bool> logout({
    @required String token,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var ret = await api.logout(token);
    if (ret) {
      prefs.remove("usertoken");
      await db.deleteUsers();
    }
    return ret;
  }

  Future<String> signup({
    @required String name,
    @required String username,
    @required String password,
  }) async {

    User user = await api.register(name, username, password);

    await db.saveUser(user);

    return user.token;
  }

  Future<void> deleteToken() async {
    /// delete from keystore/keychain
    await db.deleteUsers();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('usertoken', "");
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('usertoken', token);
    return;
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.get("usertoken") != ""?true:false;
  }

  Future<User> getUser(String token) async {
    return db.getUser(token);
  }

  Future<bool> saveMyLocation({
    @required String token,
    @required double lat,
    @required double long,
  }) async {
    bool success = await api.updateMyLocation(token, lat, long);
    return success;
  }

  Future<List> getNearbyUsers({
    @required String token,
  }) async {
    List results = await api.getNearbyUsers(token);
    return results;
  }

  Future<Map> getMyLocation({
    @required String token
  }) async {
    Map data = await api.getMyLocation(token);
    return data;
  }

  Future<List> getCompletedTickets({
    @required String token,
  }) async {
    List results = await api.getCompletedTickets(token);
    return results;
  }

  Future<List> getUpcomingTickets({
    @required String token,
    @required String date,
  }) async {
    List results = await api.getUpcomingTickets(token, date);
    return results;
  }

  Future<Map> ticket({
    @required String ticket,
    @required String token
  }) async {
    Map data = await api.ticket(ticket, token);
    return data;
  }

  Future<Map> addTicket({
    @required String token,
    @required String date,
    @required String pickup,
    @required double plat,
    @required double plng,
    @required String dropoff,
    @required double dlat,
    @required double dlng,
    @required String dist,
    @required String dur,
    @required String notes,
    @required String promo,
  }) async {
    Map data = await api.addTicket(token, date, pickup, plat, plng, dropoff, dlat, dlng, dist, dur, notes, promo);
    return data;
  }

  Future<Map> isTicketAccepted({
    @required String ticket,
    @required String token
  }) async {
    Map data = await api.isTicketAccepted(ticket, token);
    return data;
  }

  Future<bool> confirmTicket({
    @required String ticket,
    @required String token
  }) async {
    bool success = await api.confirmTicket(ticket, token);
    return success;
  }

  Future<Map> trackerDriver({
    @required String ticket,
    @required String token
  }) async {
    Map data = await api.trackerDriver(ticket, token);
    return data;
  }

  Future<bool> dropoffTicket({
    @required String ticket,
    @required String token,
    @required String lat,
    @required String lng
  }) async {
    bool success = await api.dropoffTicket(ticket, token, lat, lng);
    return success;
  }

  Future<bool> saveTicketReview({
    @required String ticket,
    @required String token,
    @required String review,
    @required double rating,
  }) async {
    bool success = await api.saveTicketReview(ticket, token, review, rating);
    return success;
  }


  Future<bool> cancelTicket({
    @required String ticket,
    @required String token
  }) async {
    bool success = await api.cancelTicket(ticket, token);
    return success;
  }


  Future<bool> saveProfile ({
    @required String token,
    @required String name,
    @required String contact,
    @required String email,
    @required String gender,
    @required String dob,
    @required String address,
    @required var image,
  }) async {
    String imgstr = "";
    if (image != null) {
      imgstr = base64Encode(image.readAsBytesSync());
    }
    bool success = await api.saveProfile(token, name, contact, email, gender, dob, address, imgstr);
    if (success) {
      User user = await this.getUser(token);
      user.fullname = name;
      user.contact = contact;
      user.email = email;
      user.gender = gender;
      user.dob = dob;
      user.address = address;

      db.deleteUsers();
      db.saveUser(user);
    }
    return success;
  }

  Future<List> getReviews({
    @required String token,
  }) async {
    List results = await api.getReviews(token);
    return results;
  }

  Future<List> getPaymentCards({
    @required String token,
  }) async {
    List results = await api.getPaymentCards(token);
    return results;
  }

  Future<Map> card({
    @required String card,
    @required String token
  }) async {
    Map data = await api.card(card, token);
    return data;
  }

  Future<bool> saveCard ({
    @required String token,
    @required String card,
    @required String name,
    @required String number,
    @required String month,
    @required String year,
    @required String cvv,
    @required String def,
  }) async {
    bool success = await api.saveCard(token, card, name, number, month, year, cvv, def);
    return success;
  }

  Future<bool> deleteCard ({
    @required String token,
    @required String card,
  }) async {
    bool success = await api.deleteCard(token, card);
    return success;
  }


  Future<Map> saveVoucher ({
    @required String token,
    @required String id,
    @required String voucher,
  }) async {
    Map resp = await api.saveVoucher(token, id, voucher);
    return resp;
  }

  Future<List> getVouchers({
    @required String token,
  }) async {
    List results = await api.getVouchers(token);
    return results;
  }

  Future<Map> voucher({
    @required String card,
    @required String token
  }) async {
    Map data = await api.voucher(card, token);
    return data;
  }

  Future<bool> deleteVoucher({
    @required String token,
    @required String card,
  }) async {
    bool success = await api.deleteVoucher(token, card);
    return success;
  }


}