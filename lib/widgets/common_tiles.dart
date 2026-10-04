import 'package:flutter/material.dart';
import '../models/home_listing.dart';
import '../models/vehicle_listing.dart';
import '../models/tour_guide.dart';

// ==========================================
// HOME TILE (horizontal card)
// ==========================================
class HomeTile extends StatelessWidget {
  final HomeListing listing;
  final VoidCallback onTap;
  const HomeTile({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: listing.coverPhoto.isNotEmpty
                    ? Image.network(
                        listing.coverPhoto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.stayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: Color(0xFFF3BDC3)),
                      const SizedBox(width: 2),
                      const Text('New',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const Spacer(),
                      Text(listing.priceLabel,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFFFF0F3),
      child: const Center(
        child: Icon(Icons.home_work_rounded,
            size: 50, color: Color(0xFFF3BDC3)),
      ),
    );
  }
}

// ==========================================
// VEHICLE TILE
// ==========================================
class VehicleTile extends StatelessWidget {
  final VehicleListing vehicle;
  final VoidCallback onTap;
  const VehicleTile({super.key, required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: vehicle.coverPhoto.isNotEmpty
                    ? Image.network(vehicle.coverPhoto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayTitle.isNotEmpty
                        ? vehicle.displayTitle
                        : vehicle.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        vehicle.rentalMode == 'Self-drive'
                            ? Icons.person_outline
                            : vehicle.rentalMode == 'Chauffeur-driven'
                                ? Icons.support_agent
                                : Icons.swap_horiz_rounded,
                        size: 12,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          vehicle.modeShort,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: Color(0xFFF3BDC3)),
                      const SizedBox(width: 2),
                      Text(vehicle.ratingLabel,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const Spacer(),
                      Text(vehicle.priceLabel,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFFCE4EC),
      child: const Center(
        child: Icon(Icons.directions_car_rounded,
            size: 50, color: Color(0xFFE91E63)),
      ),
    );
  }
}

// ==========================================
// GUIDE TILE
// ==========================================
class GuideTile extends StatelessWidget {
  final TourGuide guide;
  final VoidCallback onTap;
  const GuideTile({super.key, required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 130,
                width: double.infinity,
                child: guide.photos.isNotEmpty
                    ? Image.network(
                        guide.photos.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          guide.displayName.isNotEmpty
                              ? guide.displayName
                              : guide.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.verified_rounded,
                          size: 14, color: Color(0xFFE91E63)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guide.specialties.isNotEmpty
                        ? guide.specialties.take(2).join(' · ')
                        : guide.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: Color(0xFFF3BDC3)),
                      const SizedBox(width: 2),
                      Text(guide.ratingLabel,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const Spacer(),
                      Text(guide.priceLabel,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFFCE4EC),
      child: Center(
        child: Text(
          guide.initial,
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE91E63),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// STAR ROW (half-star support)
// ==========================================
class StarRow extends StatelessWidget {
  final double rating;
  final double size;
  const StarRow({super.key, required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        final IconData icon;
        if (rating >= starValue) {
          icon = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        return Icon(icon, size: size, color: const Color(0xFFE91E63));
      }),
    );
  }
}