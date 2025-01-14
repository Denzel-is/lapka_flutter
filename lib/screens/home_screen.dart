import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  final List<Map<String, String>> promos = mockPromos;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Верх: fade-анимация текста "Добро пожаловать в LAPKA"
    // Ниже: прокрутка акций
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0), Color(0xFFE040FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                'Добро пожаловать в\nLAPKA',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.promos.length,
                itemBuilder: (context, index) {
                  final promo = widget.promos[index];
                  return Card(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        if (promo['imageUrl'] != null)
                          Ink.image(
                            image: NetworkImage(promo['imageUrl']!),
                            fit: BoxFit.cover,
                            height: 200,
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_offer,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  promo['title'] ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (promo['desc'] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 18),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    promo['desc'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
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
