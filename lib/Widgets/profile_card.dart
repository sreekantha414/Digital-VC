import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../Model/user_profile.dart';
import '../Screens/create_card_screen.dart';
import '../Services/vcf_service.dart';
import '../Theme/theme.dart';

class ProfileCard extends StatefulWidget {
  final VisitingCard profile;
  final bool showQR;
  final File? imageFile;
  final VoidCallback? onImagePick;

  const ProfileCard({required this.profile, this.showQR = false, this.imageFile, this.onImagePick});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () async {
                final path = await VCFService.createVcfFile(widget.profile);
                final uri = Uri(scheme: 'nfcqrprofile', path: 'vcf', queryParameters: {'file': path});
                await Share.share(uri.toString());
              },
              icon: Icon(Icons.share, color: AppColors.darkPurple),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar with picker
              GestureDetector(
                onTap: widget.onImagePick,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 105,
                      width: 105,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: Offset(0, 6), // soft downward glow
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.lightPurple,
                      backgroundImage: widget.imageFile != null ? FileImage(widget.imageFile!) : null,
                      child:
                          widget.imageFile == null
                              ? Text(
                                (widget.profile.fields['name']?.trim().isNotEmpty == true)
                                    ? widget.profile.fields['name']!.trim()[0].toUpperCase()
                                    : 'N/A',
                                style: TextStyle(fontSize: 36, color: Colors.white),
                              )
                              : null,
                    ),
                    Positioned(bottom: 4, right: 4, child: Icon(Icons.camera_alt, color: AppColors.lightPurple, size: 20)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.profile.fields['name'] ?? 'N/A',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 4),
              Text(widget.profile.fields['jobTitle'] ?? 'N/A', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoTile(Icons.apartment, 'Business Name', widget.profile.fields['company'] ?? 'N/A'),

                  IconButton(
                    onPressed: () async {
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateCardScreen(existingCard: widget.profile)),
                      );
                      if (result == true) {}
                    },
                    icon: Icon(Icons.edit, color: AppColors.darkPurple),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _infoTile(Icons.email, 'Email', widget.profile.fields['email'] ?? 'N/A'),
              const SizedBox(height: 12),

              _infoTile(Icons.phone, 'Phone', widget.profile.fields['phone'] ?? 'N/A'),
              const SizedBox(height: 12),
              _infoTile(FontAwesomeIcons.link, 'Website', widget.profile.fields['website'] ?? 'N/A'),

              const SizedBox(height: 12),

              _infoTile(FontAwesomeIcons.locationDot, 'Business Address', widget.profile.fields['address'] ?? 'N/A'),

              ..._buildOptionalFields(),
              // QR Section
              if (widget.showQR) ...[
                const SizedBox(height: 25),
                Divider(),
                const SizedBox(height: 12),
                Text("Scan to View Profile", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                QrImageView(
                  data: json.encode(widget.profile.toMap()),
                  size: 290,
                  version: QrVersions.auto,
                  backgroundColor: Colors.transparent,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.circle,
                    color: Color(0xFF4A148C), // Deep purple for contrast
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: Color(0xFF9575CD), // darkPurple for modules
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptionalFields() {
    final optionalData = [
      [FontAwesomeIcons.list, 'Business Category', 'category'],
      [FontAwesomeIcons.fileLines, 'Business Description', 'description'],
      [FontAwesomeIcons.clock, 'Business Hours', 'hours'],
      [FontAwesomeIcons.facebook, 'Facebook', 'facebook'],
      [FontAwesomeIcons.instagram, 'Instagram', 'instagram'],
      [FontAwesomeIcons.linkedin, 'LinkedIn', 'linkedin'],
      [FontAwesomeIcons.youtube, 'YouTube', 'youtube'],
      [FontAwesomeIcons.twitter, 'Twitter', 'twitter'],
      [FontAwesomeIcons.bookOpen, 'Catalog', 'catalog'],
      [FontAwesomeIcons.tags, 'Labels / Tags', 'tags'],
    ];

    return optionalData
        .where((item) => widget.profile.fields[item[2]] != null && widget.profile.fields[item[2]]!.toString().trim().isNotEmpty)
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: _infoTile(item[0] as IconData, item[1] as String, widget.profile.fields[item[2]] ?? ''),
          ),
        )
        .toList();
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        FaIcon(icon, color: AppColors.lightPurple),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          ],
        ),
      ],
    );
  }
}
