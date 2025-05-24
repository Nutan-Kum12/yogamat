import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductShowcaseScreen extends StatefulWidget {
  const ProductShowcaseScreen({Key? key}) : super(key: key);

  @override
  _ProductShowcaseScreenState createState() => _ProductShowcaseScreenState();
}

class _ProductShowcaseScreenState extends State<ProductShowcaseScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final products = await databaseService.getProducts();
      
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading products: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openProductLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the link'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_products.isEmpty && !_isLoading) {
      _products = [
        {
          'id': '1',
          'name': 'Smart Yoga Mat Pro',
          'description': 'Our flagship smart yoga mat with pressure sensors and heating elements',
          'imageUrl': 'https://example.com/yoga_mat_pro.jpg',
          'price': '\$199.99',
          'link': 'https://example.com/products/yoga-mat-pro',
          'isNew': true,
        },
        {
          'id': '2',
          'name': 'Yoga Mat Companion App Premium',
          'description': 'Unlock advanced features with our premium subscription',
          'imageUrl': 'https://example.com/app_premium.jpg',
          'price': '\$9.99/month',
          'link': 'https://example.com/products/app-premium',
          'isNew': true,
        },
        {
          'id': '3',
          'name': 'Yoga Blocks - Set of 2',
          'description': 'High-density foam blocks for support and stability',
          'imageUrl': 'https://example.com/yoga_blocks.jpg',
          'price': '\$24.99',
          'link': 'https://example.com/products/yoga-blocks',
          'isNew': false,
        },
        {
          'id': '4',
          'name': 'Smart Water Bottle',
          'description': 'Track your hydration with our smart water bottle',
          'imageUrl': 'https://example.com/water_bottle.jpg',
          'price': '\$39.99',
          'link': 'https://example.com/products/water-bottle',
          'isNew': true,
        },
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products & Features'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Products & Features',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover our latest offerings to enhance your yoga experience',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),
                    
                    // New products
                    ...(_products
                        .where((product) => product['isNew'] == true)
                        .map((product) => _buildProductCard(product, true))),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      'All Products',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // All products
                    ...(_products.map((product) => _buildProductCard(product, false))),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, bool highlightNew) {
    final bool isNew = product['isNew'] == true;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  'assets/images/placeholder.jpg',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (isNew && highlightNew)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Product details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product['name'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Text(
                      product['price'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product['description'],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openProductLink(product['link']),
                    child: const Text('Learn More'),
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
