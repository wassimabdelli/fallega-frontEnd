import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../main.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';

enum PaymentMethod { bank, card, cash }

class BookingPaymentPage extends StatefulWidget {
  final int eventId;
  const BookingPaymentPage({super.key, required this.eventId});
  @override
  State<BookingPaymentPage> createState() => _BookingPaymentPageState();
}

class _BookingPaymentPageState extends State<BookingPaymentPage> {
  PaymentMethod? method;
  int step = 1;
  String? uploadedFile;

  final event = {'title': 'Randonnée au Mont Blanc', 'date': '15 Décembre 2024', 'price': 45};

  int get maxSteps => switch (method) { PaymentMethod.card => 6, _ => 3 };

  void next() => setState(() {
        if (step < maxSteps) {
          step++;
        }
      });

  @override
  Widget build(BuildContext context) {
    if (method == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back, color: kDark, size: 24),
                    SizedBox(width: 12),
                    Text('Réservation', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Récapitulatif', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          _KV('Événement', (event['title'] as String)),
                          _KV('Date', (event['date'] as String)),
                          const Divider(),
                          _KV('Total', '${event['price']}€', valueColor: kPrimary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Choisissez votre méthode de paiement', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _MethodCard(
                      iconBg: Colors.blue.shade100,
                      iconColor: Colors.blue.shade600,
                      icon: Icons.apartment,
                      title: 'Virement bancaire',
                      subtitle: 'Paiement sécurisé par virement',
                      onTap: () => setState(() => method = PaymentMethod.bank),
                    ),
                    _MethodCard(
                      iconBg: Colors.green.shade100,
                      iconColor: Colors.green.shade600,
                      icon: Icons.credit_card,
                      title: 'Carte bancaire',
                      subtitle: 'Paiement instantané par carte',
                      onTap: () => setState(() {
                        method = PaymentMethod.card;
                        step = 1;
                      }),
                    ),
                    _MethodCard(
                      iconBg: Colors.orange.shade100,
                      iconColor: Colors.orange.shade600,
                      icon: Icons.payments_outlined,
                      title: 'Paiement en espèces',
                      subtitle: 'Payer sur place',
                      onTap: () => setState(() => method = PaymentMethod.cash),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNav(selectedIndex: 1, onSelected: _noop),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          if (step == 1) {
                            method = null;
                          } else {
                            step--;
                          }
                        }),
                      icon: const Icon(Icons.arrow_back, color: kDark),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        switch (method) {
                          PaymentMethod.card => 'Paiement par carte',
                          PaymentMethod.bank => 'Virement bancaire',
                          PaymentMethod.cash => 'Paiement en espèces',
                          null => '',
                        },
                        style: const TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(maxSteps, (i) {
                      final active = i < step;
                      return Expanded(
                        child: Container(
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(color: active ? kPrimary : Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text('Étape $step/$maxSteps', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  if (method == PaymentMethod.bank) ...[
                    if (step == 1)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Informations bancaires', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  _KV('Bénéficiaire', 'Fallega SAS'),
                                  _KV('IBAN', 'FR76 1234 5678 9012 3456'),
                                  _KV('BIC', 'BNPAFRPP'),
                                  _KV('Montant', '${event['price']}€', valueColor: kPrimary),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Veuillez effectuer le virement avec la référence : REF-123', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    if (step == 2)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Justificatif de paiement', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => setState(() => uploadedFile = 'justificatif.pdf'),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    const Icon(Icons.upload_file, color: Colors.grey, size: 48),
                                    const SizedBox(height: 8),
                                    Text(uploadedFile ?? 'Cliquez pour télécharger', style: const TextStyle(color: kDark)),
                                    const SizedBox(height: 4),
                                    const Text('PDF, JPG, PNG (Max 5MB)', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (step == 3)
                      AppCard(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const Icon(Icons.check, color: Colors.green, size: 40),
                            ),
                            const SizedBox(height: 8),
                            const Text('Validation en cours', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            const Text('Votre paiement sera vérifié sous 24-48h', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                  ],
                  if (method == PaymentMethod.card) ...[
                    if (step == 1)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Informations personnelles', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            _TextField(hint: 'Nom complet'),
                            SizedBox(height: 8),
                            _TextField(hint: 'Email'),
                            SizedBox(height: 8),
                            _TextField(hint: 'Téléphone'),
                          ],
                        ),
                      ),
                    if (step == 2)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Adresse de facturation', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            _TextField(hint: 'Adresse'),
                            SizedBox(height: 8),
                            Row(children: [Expanded(child: _TextField(hint: 'Code postal')), SizedBox(width: 12), Expanded(child: _TextField(hint: 'Ville'))]),
                            SizedBox(height: 8),
                            _TextField(hint: 'Pays'),
                          ],
                        ),
                      ),
                    if (step == 3)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Informations de carte', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            _TextField(hint: 'Numéro de carte'),
                            SizedBox(height: 8),
                            _TextField(hint: 'Nom sur la carte'),
                            SizedBox(height: 8),
                            Row(children: [Expanded(child: _TextField(hint: 'MM/AA')), SizedBox(width: 12), Expanded(child: _TextField(hint: 'CVV'))]),
                          ],
                        ),
                      ),
                    if (step == 4)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Vérification', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            Text('Un code de vérification a été envoyé par SMS', style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 8),
                            _TextField(hint: 'Code de vérification'),
                          ],
                        ),
                      ),
                    if (step == 5)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Récapitulatif', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            _KV('Événement', (event['title'] as String)),
                            _KV('Date', (event['date'] as String)),
                            _KV('Carte', '**** **** **** 1234'),
                            const Divider(),
                            _KV('Total', '${event['price']}€', valueColor: kPrimary),
                          ],
                        ),
                      ),
                    if (step == 6)
                      AppCard(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const Icon(Icons.check, color: Colors.green, size: 40),
                            ),
                            const SizedBox(height: 8),
                            const Text('Paiement confirmé !', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            const Text('Votre réservation a été confirmée avec succès', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                  ],
                  if (method == PaymentMethod.cash) ...[
                    if (step == 1)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Informations', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            SizedBox(height: 8),
                            _TextField(hint: 'Nom complet'),
                            SizedBox(height: 8),
                            _TextField(hint: 'Email'),
                            SizedBox(height: 8),
                            _TextField(hint: 'Téléphone'),
                            SizedBox(height: 8),
                            _InfoBox(text: 'Le paiement en espèces sera effectué sur place le jour de l\'événement.'),
                          ],
                        ),
                      ),
                    if (step == 2)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Confirmation', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            _KV('Événement', (event['title'] as String)),
                            _KV('Date', (event['date'] as String)),
                            _KV('Mode de paiement', 'Espèces sur place'),
                            const Divider(),
                            _KV('À payer sur place', '${event['price']}€', valueColor: kPrimary),
                          ],
                        ),
                      ),
                    if (step == 3)
                      AppCard(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const Icon(LucideIcons.check, color: Colors.green, size: 40),
                            ),
                            const SizedBox(height: 8),
                            const Text('Réservation confirmée !', style: TextStyle(color: kDark, fontSize: 18, fontWeight: FontWeight.w600)),
                            Text('N\'oubliez pas d\'apporter ${event['price']}€ en espèces le jour J', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                  ],
                  AppButton(
                    fullWidth: true,
                    onPressed: next,
                    child: Text(step == maxSteps ? 'Terminer' : 'Continuer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1, onSelected: _noop),
    );
  }
}

class _KV extends StatelessWidget {
  final String keyText;
  final String valueText;
  final Color? valueColor;
  const _KV(this.keyText, this.valueText, {this.valueColor});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(keyText, style: const TextStyle(color: Colors.grey)),
          Text(valueText, style: TextStyle(color: valueColor ?? kDark)),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String hint;
  const _TextField({required this.hint});
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12, width: 2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12, width: 2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimary, width: 2)),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.orange.shade50, border: Border.all(color: Colors.orange.shade200), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: Colors.orange.shade700)),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MethodCard({required this.iconBg, required this.iconColor, required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: kDark, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _noop(int _) {}
