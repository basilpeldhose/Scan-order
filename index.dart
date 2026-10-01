import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// ---------- Colors ----------
const Color green = Color(0xFF1B4D2E);

// ---------- Simple data classes ----------
class Dish {
  String name;
  String description;
  int price;
  String category;
  String emoji;

  Dish(this.name, this.description, this.price, this.category, this.emoji);
}

class CartItem {
  Dish dish;
  int qty;

  CartItem(this.dish, this.qty);
}

// ---------- Global data ----------
List<CartItem> cart = [];

List<Dish> allDishes = [
  Dish(
    'Paneer Tikka',
    'Cottage cheese marinated in spices and grilled.',
    220,
    'Starters',
    '🍢',
  ),
  Dish(
    'Veg Biryani',
    'Aromatic basmati rice cooked with veggies.',
    250,
    'Main Course',
    '🍛',
  ),
  Dish(
    'Butter Naan',
    'Soft and fluffy naan with butter.',
    60,
    'Main Course',
    '🫓',
  ),
  Dish('Masala Chai', 'Hot tea with milk and spices.', 30, 'Beverages', '☕'),
  Dish('Lime Soda', 'Fresh and fizzy lime drink.', 40, 'Beverages', '🥤'),
  Dish(
    'Gulab Jamun',
    'Sweet fried dumplings in sugar syrup.',
    70,
    'Desserts',
    '🍮',
  ),
];

List<String> categories = [
  'All',
  'Starters',
  'Main Course',
  'Beverages',
  'Desserts',
];

// Add dish to cart (if already there, increase quantity)
void addToCart(Dish dish) {
  for (int i = 0; i < cart.length; i++) {
    if (cart[i].dish.name == dish.name) {
      cart[i].qty++;
      return;
    }
  }
  cart.add(CartItem(dish, 1));
}

int cartCount() {
  int total = 0;
  for (int i = 0; i < cart.length; i++) {
    total = total + cart[i].qty;
  }
  return total;
}

int cartSubtotal() {
  int total = 0;
  for (int i = 0; i < cart.length; i++) {
    total = total + cart[i].dish.price * cart[i].qty;
  }
  return total;
}

// ---------- App ----------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Scan Order',
      theme: ThemeData(primaryColor: green),
      home: ScanScreen(),
    );
  }
}

// ---------- Screen 1: Scan QR ----------
class ScanScreen extends StatelessWidget {
  final TextEditingController tableController = TextEditingController();

  ScanScreen({super.key});

  void openMenu(BuildContext context, String table) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(table)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[900],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Scan QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Scan the QR code on your table to view the menu',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 30),
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.qr_code_2, size: 150),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  minimumSize: Size(200, 48),
                ),
                onPressed: () {
                  // Demo scan: goes directly to Table 12
                  openMenu(context, '12');
                },
                child: Text(
                  'Scan QR (Demo)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'or enter table number',
                style: TextStyle(color: Colors.greenAccent),
              ),
              SizedBox(height: 10),
              TextField(
                controller: tableController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Table number',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  if (tableController.text != '') {
                    openMenu(context, tableController.text);
                  }
                },
                child: Text('Continue', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Screen 2: Home / Menu ----------
class HomeScreen extends StatefulWidget {
  final String table;

  const HomeScreen(this.table, {super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    // Filter dishes by category and search text
    List<Dish> shownDishes = [];
    for (int i = 0; i < allDishes.length; i++) {
      Dish d = allDishes[i];
      bool categoryOk =
          selectedCategory == 'All' || d.category == selectedCategory;
      bool searchOk = d.name.toLowerCase().contains(searchText.toLowerCase());
      if (categoryOk && searchOk) {
        shownDishes.add(d);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: Text('Table ${widget.table} • Hotel Green View'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(widget.table),
                    ),
                  ).then((value) {
                    setState(() {}); // refresh cart count
                  });
                },
              ),
              if (cartCount() > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cartCount()}',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Food',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Good Mood',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Delicious food, made with love ❤️',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          // Search box
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for dishes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Category buttons
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (int i = 0; i < categories.length; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(categories[i]),
                      selected: selectedCategory == categories[i],
                      selectedColor: Colors.green[200],
                      onSelected: (value) {
                        setState(() {
                          selectedCategory = categories[i];
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Dish list
          Expanded(
            child: ListView.builder(
              itemCount: shownDishes.length,
              itemBuilder: (context, index) {
                Dish dish = shownDishes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Text(dish.emoji, style: TextStyle(fontSize: 36)),
                    title: Text(
                      dish.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${dish.description}\n₹${dish.price}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: Icon(Icons.add_circle, color: green, size: 32),
                      onPressed: () {
                        setState(() {
                          addToCart(dish);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${dish.name} added to cart'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Screen 3: Cart ----------
class CartScreen extends StatefulWidget {
  final String table;

  const CartScreen(this.table, {super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    int subtotal = cartSubtotal();
    int taxes = (subtotal * 0.10).round(); // 10% taxes
    int total = subtotal + taxes;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        title: Text('Your Cart (Table ${widget.table})'),
      ),
      body: cart.isEmpty
          ? Center(
              child: Text('Your cart is empty', style: TextStyle(fontSize: 18)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      CartItem item = cart[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Text(
                            item.dish.emoji,
                            style: TextStyle(fontSize: 32),
                          ),
                          title: Text(item.dish.name),
                          subtitle: Text('₹${item.dish.price}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    if (item.qty > 1) {
                                      item.qty--;
                                    } else {
                                      cart.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text(
                                '${item.qty}',
                                style: TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    item.qty++;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    cart.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Bill
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Subtotal'), Text('₹$subtotal')],
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Taxes & Charges'), Text('₹$taxes')],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹$total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ConfirmScreen(widget.table, total),
                            ),
                          );
                        },
                        child: Text(
                          'Place Order | ₹$total',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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

// ---------- Screen 4: Order Confirmed ----------
class ConfirmScreen extends StatelessWidget {
  final String table;
  final int total;

  const ConfirmScreen(this.table, this.total, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: green,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Order Confirmed! 🎉',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your order has been received',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order ID'),
                            Text(
                              '#GV12345',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Estimated Time'),
                            Text(
                              '20-25 min',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text('🍽️', style: TextStyle(fontSize: 60)),
                    SizedBox(height: 10),
                    Text('Table $table  •  Total ₹$total'),
                    SizedBox(height: 10),
                    Text("We'll notify you when your order is on the way."),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Order status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  statusItem(Icons.check_circle, 'Confirmed', true),
                  statusItem(Icons.soup_kitchen, 'Preparing', false),
                  statusItem(Icons.delivery_dining, 'On the way', false),
                  statusItem(Icons.restaurant, 'Served', false),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(200, 48),
                ),
                onPressed: () {
                  cart.clear(); // empty the cart after ordering
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(table)),
                    (route) => false,
                  );
                },
                child: Text('Back to Menu', style: TextStyle(color: green)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget statusItem(IconData icon, String label, bool active) {
    return Column(
      children: [
        Icon(
          icon,
          color: active ? Colors.greenAccent : Colors.white38,
          size: 32,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
