import 'package:flutter/material.dart';
import 'package:kampus_konnect/domains/homepage/unsold_post_card.dart';
import 'dart:math';
import '../../app/decorations.dart';
import 'post_card_provider.dart';
import 'package:provider/provider.dart';
import 'product_details/product_details.dart';
import '../auth/services/auth.dart';
import '../../wishlist/wishlist_service.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchPosts('');
  }

  Future<void> _fetchPosts(query) async {
    print('Its working');
    final email = await _authService.getEmail();
    final token = await _authService.getToken();
    final postCardProvider =
        Provider.of<PostCardProvider>(context, listen: false);
    if (email != null && token != null) {
      await postCardProvider.fetchPostCards(query);
    }
  }

  bool displayAll = false;
  bool isRefreshing = false;

  Widget _appbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        height: 50,
        child: Container(
          
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 5),
          child: 
            
            TextField(
              textAlignVertical: TextAlignVertical.top,
              style: mytext.headingtext1(fontSize: 23, context),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search,
                size: 30,
                color: Colors.white,),
                border: InputBorder.none,
                hintText: "Type to search...",
              ),
              onSubmitted: (query) => {
                _fetchPosts(query)
              },
            ),
            
          
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    await _fetchPosts('');
    setState(() {
      isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final postCardProvider = Provider.of<PostCardProvider>(context);

    return Scaffold(
      appBar: null,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(top: 10),
              sliver: SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                elevation: 0,
                collapsedHeight: 60,
                flexibleSpace: _appbar(context),
                expandedHeight: 40,
                foregroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 0),
                      child: Text('Newly Arrived',
                          style: mytext.headingbold(fontSize: 17, context)),
                    ),
                    Expanded(child: SizedBox()),
                    Padding(
                      padding: const EdgeInsets.only(top: 0, right: 20),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            displayAll = !displayAll;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: displayAll
                                ? Theme.of(context).colorScheme.background
                                : Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(displayAll ? 'View Less' : 'View All',
                              style:
                                  mytext.headingtext1(fontSize: 15, context)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220.0,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 20.0,
                  childAspectRatio: 0.8,
                  mainAxisExtent: 250,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (!displayAll && index >= 7) {
                      return Container();
                    }
                    return ProductTile(
                      postCard: postCardProvider.productCard[index],
                    );
                  },
                  childCount: displayAll
                      ? postCardProvider.productCard.length
                      : min(7, postCardProvider.productCard.length),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductTile extends StatefulWidget {
  final PostCard postCard;

  const ProductTile({
    Key? key,
    required this.postCard,
  }) : super(key: key);

  @override
  _ProductTileState createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
  }

  // void _toggleFavorite() async {
  //   try {
  //     if (isFavorite) {
  //       await widget.wishlistService.removeFromWishlist(widget.postCard.postId);
  //     } else {
  //       await widget.wishlistService.addToWishlist(widget.postCard.postId);
  //     }
  //     setState(() {
  //       isFavorite = !isFavorite;
  //     });
  //   } catch (e) {
  //     print('Error toggling wishlist: $e');
  //     // Handle error or show a snackbar
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              id: widget.postCard.postId,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: widget.postCard.image.isNotEmpty
                            ? Image.network(
                                widget.postCard.image,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.person,
                                size: 150,
                                color: Colors.white,
                              ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.postCard.title,
                        style: mytext.headingtext1(fontSize: 13, context),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Row(
                        children: [
                          Text(
                            '₹${widget.postCard.price}',
                            style: mytext.headingbold(fontSize: 15, context),
                            textAlign: TextAlign.left,
                          ),
                          Expanded(child: SizedBox()),
                          GestureDetector(
                            //onTap: _toggleFavorite,
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 25,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ],
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
