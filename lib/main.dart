import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:warehouse_receipt/data/data_sources/receipt_remote_data_source.dart';
import 'package:warehouse_receipt/data/repositories/receipt_repository_impl.dart';
import 'package:warehouse_receipt/firebase_options.dart';
import 'package:warehouse_receipt/providers/receipt_provider.dart';
import 'package:warehouse_receipt/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ReceiptRemoteDataSource>(
          create: (_) => ReceiptRemoteDataSourceImpl(firestore: FirebaseFirestore.instance),
        ),
        ProxyProvider<ReceiptRemoteDataSource, ReceiptRepositoryImpl>(
          update: (_, dataSource, __) => ReceiptRepositoryImpl(dataSource),
        ),
        ChangeNotifierProxyProvider<ReceiptRepositoryImpl, ReceiptProvider>(
          create: (context) => ReceiptProvider(
            context.read<ReceiptRepositoryImpl>(),
          ),
          update: (_, repository, __) => ReceiptProvider(repository),
        ),
      ],
      child: MaterialApp(
        title: 'Warehouse Receipt',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
