import 'package:flutter/material.dart';
import 'package:kampus_konnect/domains/chat/chat_detail_screen.dart';
import 'package:provider/provider.dart';
import 'product_details_provider.dart'; 
class ProductDetailsPage extends StatefulWidget {
  final int id;

  const ProductDetailsPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool dealInitiated = false;
  bool isWishlisted=false;

  @override
  void initState() {
    super.initState();
    print(widget.id);
    Provider.of<ProductDetailsProvider>(context, listen: false)
        .fetchPost(widget.id);
        
  }


  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<ProductDetailsProvider>(context);
    final post = postProvider.post;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          post?.title ?? 'Loading...', // Use the title of the product
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: post == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          if (post.imageUrls.isNotEmpty)
                            Container(
                              height: 250, // Adjust height as necessary
                              child: PageView.builder(
                                itemCount: post.imageUrls.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    post.imageUrls[index],
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            )
                          else
                            Center(
                              child: Icon(
                                Icons.person,
                                size: 150,
                                color: Colors.white,
                              ),
                            ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  minimumSize:
                                      MaterialStateProperty.all(Size(100, 60)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    isWishlisted ? Colors.red : Colors.white,
                                  ),
                                ),
                                child: Text(
                                  isWishlisted
                                      ? 'Remove From Favorites'
                                      : 'Add To favourites',
                                  style: TextStyle(
                                    color: isWishlisted
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                onPressed: null
                              ),
                              ElevatedButton(
                                style: ButtonStyle(
                                  minimumSize:
                                      MaterialStateProperty.all(Size(100, 60)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    dealInitiated
                                        ? Color.fromARGB(255, 12, 69, 7)
                                        : Colors.green,
                                  ),
                                ),
                                child: Text(
                                  dealInitiated ? 'Chat Now' : 'Make a Deal',
                                ),
                                onPressed: () {
                                  setState(() {
                                    dealInitiated = !dealInitiated;
                                     Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                           ChatDetailScreen(postId: post.postId)
                                      ),
                                    );
                                  });
                                  // Handle chat or deal initiation action
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '₹${post.price}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            post.body,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Seller information card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seller: ${post.owner}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Address card
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Address:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Sample Address', // Use the address from your data
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              minimumSize:
                                  MaterialStateProperty.all(Size(120, 60)),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.blue,
                              ),
                            ),
                            onPressed: () {
                              // Handle go to address action
                            },
                            child: Text(
                              'Go to Address',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}
