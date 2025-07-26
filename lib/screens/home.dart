import 'package:flutter/material.dart';
import 'package:unsplash_clone/components/item_card.dart';
import 'package:unsplash_clone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:unsplash_clone/screens/cart.dart';

class HomePage extends StatelessWidget {
  // Data item dijadikan const supaya HomePage bisa const
  static const List<Map<String, dynamic>> items = [
    {
      "title": "Foto Wisuda",
      "desc": "Photoshoot graduation with properties.",
      "price": 1200000,
    },
    {
      "title": "Foto Wisuda Malam",
      "desc": "Dramatic night photoshoot with lamps and fisheye lens.",
      "price": 1500000,
    },
    {
      "title": "Photobox",
      "desc": "Create sweet moments with your loved one.",
      "price": 800000,
    },
    {
      "title": "Photobooth",
      "desc": "Capture fun moments with friends or siblings.",
      "price": 800000,
    },
    {
      "title": "Foto Studio",
      "desc": "Take beautiful portraits with your family.",
      "price": 750000,
    },
    {
      "title": "Foto Prewed",
      "desc": "Make your pre-wedding memories unforgettable.",
      "price": 1200000,
    },
  ];

  const HomePage({super.key}); // Sudah bisa const

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Belum login')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Icon profil
            const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.person, size: 30, color: Colors.black),
            ),
            const SizedBox(height: 12),

            // Hello, user + keranjang + search
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Hello, ${user.displayName ?? user.email}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis, // Biar tidak overflow
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                      color: Colors.black,
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                      color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Grid konten
            Expanded(
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ItemCard(
                    name: item['title']!,
                    price: item['price']!,
                    desc: item['desc']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
