import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'provider_detail_screen.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: const Text('Browse Providers'),
            elevation: 0,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProviderCard(
                  'City Health Specialists',
                  'Clinic',
                  4.9,
                  124,
                  'Downtown',
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBdCiuytJCU4K2UjXSqkf4CtyUZQ_1acYvR-DQo-wcu5W9eqB16ha9gIHJ96IRIrugRsdW59J7mLC_mzjHkciMaffs68dzgItdG7rVXg0zZKlcrwztkZyam1BNhyyOXFJHXfBxihqmE6z95qy9EYpQjJBAb83uu-nuz0-bGxocelptaVcuFXgY3S8WXTHeVKFUyGgpkOOOghU-t9CAr0tSr2TWvNA8mUEc_6EiSv7lLsaann2NyoQtcYEtP7Fgz83_xq4iTw0s0apI',
                  context,
                ),
                const SizedBox(height: 12),
                _buildProviderCard(
                  'Glow Up Beauty Studio',
                  'Salon',
                  4.7,
                  85,
                  'Greenwich Village',
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD58O9sAwuQeuxjkT4V7XTtAL6Bzy0PJyDdklCjNqMtSYdgsqw_jm165mnOtdWfMqFi8NTN3KqK-9YV6QT7vRdcDarbWzYsvqEK_tf3PsCT0xHh0Df_VH78ut6zqruaNVaDm3vPCqX__7XwjOeMckEj-LPNpkok4HAGWU39pu2eelNJ3H33qaqb8f-9H6cU7sxO-PFC_OVrhQr1olgpOmkGxRnYmb4sAo6VX4gN50c4NP9tYqPI2WZrkbAz6QR-AKPsPsdPIH-VdAs',
                  context,
                ),
                const SizedBox(height: 12),
                _buildProviderCard(
                  'Apex Math Tutoring',
                  'Tutor',
                  5.0,
                  42,
                  'Chelsea',
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCakLGNctXB0gYEVj5qgAugU_tlBB3lZ7HIGqlmDMg7GBBFM5KVW6N8yQE_962w4m9uY4LMrjK3__2dGL8yJzKrvUU6uGbXQdFdsoa0m9q14wOJyJDcUFXy1oaTaBamMz8r-xhxDMLEb-4QXr-Aiwg9R5LyHeHnqGpaXtEmRNYFvqde2jD7styTels2lbpUHktmpflHOWUQiK-Zh9Aha0OYqcnkQGBKEjdy-WseojLs2jBuc7uaVrn7tXmpGAlHpl8F9dInUB4xrV0',
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(
    String name,
    String type,
    double rating,
    int reviews,
    String location,
    String imageUrl,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$rating ($reviews reviews)',
                      style: const TextStyle(fontSize: 12, color: AppTheme.mutedColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  location,
                  style: const TextStyle(fontSize: 12, color: AppTheme.mutedColor),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProviderDetailScreen(
                          providerName: name,
                          providerType: type,
                          imageUrl: imageUrl,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('View Details', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
