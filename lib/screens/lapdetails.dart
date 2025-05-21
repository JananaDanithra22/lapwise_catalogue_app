import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'home.dart';
import 'package:visibility_detector/visibility_detector.dart';

class LaptopDetailsPage extends StatefulWidget {
  final String laptopId;
  const LaptopDetailsPage({super.key, required this.laptopId});

  @override
  State<LaptopDetailsPage> createState() => _LaptopDetailsPageState();