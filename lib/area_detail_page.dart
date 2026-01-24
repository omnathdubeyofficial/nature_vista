import 'package:flutter/material.dart';

class AreaDetailPage extends StatelessWidget {
  final String areaName;

  const AreaDetailPage({Key? key, required this.areaName}) : super(key: key);

  Map<String, Map<String, dynamic>> _getAreaDetails() {
    return {
      'Swimming Pool': {
        'icon': Icons.pool,
        'color': Colors.blue,
        'description': 'Olympic size swimming pool with separate kids pool area',
        'features': [
          'Temperature controlled water',
          'Lifeguard on duty',
          'Changing rooms & lockers',
          'Pool side seating'
        ],
      },
      'Basketball': {
        'icon': Icons.sports_basketball,
        'color': Colors.orange,
        'description': 'Professional basketball court with modern amenities',
        'features': [
          'Floodlights for night play',
          'Synthetic flooring',
          'Spectator seating',
          'Equipment storage'
        ],
      },
      'Tennis Courts': {
        'icon': Icons.sports_tennis,
        'color': Colors.green,
        'description': 'Two professional tennis courts',
        'features': [
          'Synthetic grass surface',
          'Night lighting',
          'Equipment available',
          'Seating gallery'
        ],
      },
      'Central Garden': {
        'icon': Icons.park,
        'color': Colors.lightGreen,
        'description': 'Beautiful landscaped central garden with water features',
        'features': [
          'Walking paths',
          'Multiple seating areas',
          'Water fountains',
          'Landscaped greenery'
        ],
      },
      'Yoga Lawn': {
        'icon': Icons.self_improvement,
        'color': Colors.teal,
        'description': 'Open yoga and meditation lawn',
        'features': [
          'Morning yoga sessions',
          'Expert trainers',
          'Peaceful environment',
          'Meditation zone'
        ],
      },
      'Kids Zone': {
        'icon': Icons.child_care,
        'color': Colors.pink,
        'description': 'Safe and modern kids play area',
        'features': [
          'Age-appropriate equipment',
          'Soft safety flooring',
          'Supervised area',
          'Sand pit & swings'
        ],
      },
      'Jogging Track': {
        'icon': Icons.directions_run,
        'color': Colors.purple,
        'description': 'Dedicated jogging and cycling track',
        'features': [
          'Rubberized surface',
          'Distance markers',
          'Well lit pathway',
          'Separate cycling lane'
        ],
      },
      'Main Building': {
        'icon': Icons.apartment,
        'color': Colors.red,
        'description': 'Modern residential towers with premium amenities',
        'features': [
          '2/3/4 BHK apartments',
          'High-speed elevators',
          'Smart home features',
          '24/7 security'
        ],
      },
      'Parking': {
        'icon': Icons.local_parking,
        'color': Colors.amber,
        'description': 'Multi-level parking facility',
        'features': [
          'Covered parking',
          'Visitor parking',
          'EV charging points',
          'CCTV surveillance'
        ],
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final details = _getAreaDetails()[areaName] ?? {};
    final icon = details['icon'] ?? Icons.place;
    final color = details['color'] ?? Colors.grey;
    final description = details['description'] ?? 'No description available';
    final features = details['features'] as List<String>? ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.3),
                  Colors.black,
                ],
              ),
            ),
          ),

          /// Content
          SafeArea(
            child: Column(
              children: [
                /// Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, color: color, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          areaName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Description Card
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'About',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                description,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Features
                        if (features.isNotEmpty) ...[
                          const Text(
                            'Features',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...features.map((feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: color,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
