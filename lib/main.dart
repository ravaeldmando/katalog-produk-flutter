import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class Produk {
  final String nama;
  final int harga;
  Produk(this.nama, this.harga);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Katalog Produk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const MainNavigationPage(),
    );
  }
}

// ===== Bagian 7: Reusable widget =====
class ProductCard extends StatelessWidget {
  final String nama;
  final int harga;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.nama,
    required this.harga,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nama,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Rp $harga', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ===== Bagian 6: BottomNavigationBar + Bagian 1: setState =====
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _tabTerpilih = 0;
  int _jumlahKeranjang = 0;

  final List<Produk> _produk = [
    Produk('Kursi Minimalis', 350000),
    Produk('Meja Kerja Kayu', 750000),
    Produk('Lampu Meja LED', 120000),
    Produk('Rak Buku Besi', 450000),
    Produk('Sofa Santai', 1500000),
  ];

  void _snack(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  void _tambahKeranjang() {
    setState(() {
      _jumlahKeranjang++;
    });
  }

  // Bagian 3 + 4.2: buka form, tunggu data balik
  Future<void> _bukaFormTambah() async {
    final hasil = await Navigator.push<Produk>(
      context,
      MaterialPageRoute(builder: (context) => const TambahProdukPage()),
    );
    if (hasil != null) {
      setState(() {
        _produk.add(hasil);
      });
      if (!mounted) return;
      _snack('Produk "${hasil.nama}" berhasil ditambahkan');
    }
  }

  // Bagian 5: AlertDialog konfirmasi hapus
  void _konfirmasiHapus(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Produk?'),
          content: Text('"${_produk[index].nama}" akan dihapus dari daftar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                final nama = _produk[index].nama;
                Navigator.pop(dialogContext);
                setState(() {
                  _produk.removeAt(index);
                });
                _snack('Produk "$nama" telah dihapus');
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Bagian 4.1: navigasi ke detail + kirim data
  void _bukaDetail(Produk p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProdukDetailPage(
          namaProduk: p.nama,
          harga: p.harga,
          onTambahKeranjang: _tambahKeranjang,
        ),
      ),
    );
  }

  Widget _badgeKeranjang() {
    return Stack(
      children: [
        IconButton(
          onPressed: () => _snack('Isi keranjang: $_jumlahKeranjang item'),
          icon: const Icon(Icons.shopping_cart),
        ),
        if (_jumlahKeranjang > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$_jumlahKeranjang',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
      ],
    );
  }

  Widget _halamanDaftar() {
    if (_produk.isEmpty) {
      return const Center(child: Text('Belum ada produk'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _produk.length,
      itemBuilder: (context, index) {
        final p = _produk[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: ProductCard(
                  nama: p.nama,
                  harga: p.harga,
                  onTap: () => _bukaDetail(p),
                ),
              ),
              IconButton(
                onPressed: () => _konfirmasiHapus(index),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final halaman = [_halamanDaftar(), const ProfilPage()];
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTerpilih == 0 ? 'Daftar Produk' : 'Profil'),
        actions: [_badgeKeranjang()],
      ),
      body: halaman[_tabTerpilih],
      floatingActionButton: _tabTerpilih == 0
          ? FloatingActionButton(
              onPressed: _bukaFormTambah,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabTerpilih,
        onTap: (index) {
          setState(() {
            _tabTerpilih = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 96),
          SizedBox(height: 12),
          Text('Nama Anda', style: TextStyle(fontSize: 20)),
          Text('NIM Anda'),
        ],
      ),
    );
  }
}

// ===== Bagian 4: Halaman detail =====
class ProdukDetailPage extends StatelessWidget {
  final String namaProduk;
  final int harga;
  final VoidCallback onTambahKeranjang;

  const ProdukDetailPage({
    super.key,
    required this.namaProduk,
    required this.harga,
    required this.onTambahKeranjang,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Icon(Icons.chair, size: 120)),
            const SizedBox(height: 16),
            Text(namaProduk,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Rp $harga', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                onTambahKeranjang();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"$namaProduk" ditambahkan ke keranjang')),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Tambah ke Keranjang'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Bagian 3: Form + validasi =====
class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        Produk(_namaController.text.trim(), int.parse(_hargaController.text)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama produk wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga wajib diisi';
                  }
                  final angka = int.tryParse(value);
                  if (angka == null || angka <= 0) {
                    return 'Harga harus berupa angka lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
