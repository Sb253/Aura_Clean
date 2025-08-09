import 'dart:typed_data';
import 'package:aura_clean/models/photo_asset.dart';
import 'package:flutter/material.dart';

class PhotoCard extends StatelessWidget {
  final PhotoAsset photoAsset;

  const PhotoCard({
    super.key,
    required this.photoAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FutureBuilder<Uint8List?>(
          future: photoAsset.entity.thumbnailData,
          builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            }
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
