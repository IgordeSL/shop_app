import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/image_network_helper.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductPage extends StatefulWidget {
  static final routeName = '/edit-product';

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage>
    with SingleTickerProviderStateMixin {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  final _imageURLFocusNode = FocusNode();
  final _productFormGlobalKey = GlobalKey<FormState>();

  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();

  bool _isInit = true;
  bool _isWaiting = false;
  bool _isEnabled = true;
  bool _isChanged = false;
  bool _isSaved = false;

  Product _edittedProduct = Product.empty();

  @override
  void initState() {
    _imageURLFocusNode.addListener(_updateImageURL);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String productId = ModalRoute.of(context).settings.arguments;

      if (productId != null) {
        _edittedProduct = Provider.of<Products>(
          context,
          listen: false,
        ).findById(productId);
      }

      _imageURLController.text = _edittedProduct.imageURL;
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLController.dispose();
    _imageURLFocusNode.removeListener(_updateImageURL);
    _imageURLFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        leading: CloseButton(),
        bottom: PreferredSize(
          child: AnimatedSize(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
            vsync: this,
            child: Container(
              child: _isWaiting ? LinearProgressIndicator(value: null) : null,
            ),
          ),
          preferredSize: const Size.fromHeight(0),
        ),
        title: Text('${_edittedProduct.id == null ? 'New' : 'Edit'} product'),
        actions: <Widget>[
          IconButton(
            icon: Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _saveProductForm,
          )
        ],
      ),
      body: Form(
        key: _productFormGlobalKey,
        onWillPop: _onWillPopForm,
        onChanged: _onFormChange,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 32,
              horizontal: 16,
            ),
            child: Column(
              children: <Widget>[
                TextFormField(
                  autofocus: true,
                  enabled: _isEnabled,
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  initialValue: _edittedProduct.title,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: _validateTitle,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  onSaved: (newValue) {
                    _edittedProduct = _edittedProduct.copyWith(
                      title: newValue,
                    );
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  enabled: _isEnabled,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    suffixIcon: Icon(Icons.attach_money_rounded),
                  ),
                  initialValue: _edittedProduct.price?.toString(),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  focusNode: _priceFocusNode,
                  validator: _validatePrice,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  onSaved: (newValue) {
                    _edittedProduct = _edittedProduct.copyWith(
                      price: double.parse(newValue),
                    );
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  enabled: _isEnabled,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  initialValue: _edittedProduct.description,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  focusNode: _descriptionFocusNode,
                  validator: _validateDescription,
                  onSaved: (newValue) {
                    _edittedProduct = _edittedProduct.copyWith(
                      description: newValue,
                    );
                  },
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 58,
                      width: 58,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageURLController.text,
                          loadingBuilder: imageNetworkLoadingBuilder,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.error_outline_rounded,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        enabled: _isEnabled,
                        decoration: InputDecoration(
                          labelText: 'Image URL',
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.url,
                        controller: _imageURLController,
                        focusNode: _imageURLFocusNode,
                        validator: _validateImageURL,
                        onSaved: (newValue) {
                          _edittedProduct = _edittedProduct.copyWith(
                            imageURL: newValue,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPopForm() async {
    if ((_isChanged && _isSaved) || !_isChanged) {
      return true;
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discart changes?'),
          content: const Text('All unsaved data will be lost.'),
          actions: [
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: const Text('Discart'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _onFormChange() {
    _isChanged = true;
  }

  void _updateImageURL() {
    if (!_imageURLFocusNode.hasFocus) {
      setState(() {});
    }
  }

  String _validateTitle(value) {
    if (value.isEmpty) {
      return 'Title must not be empty';
    } else {
      return null;
    }
  }

  String _validatePrice(value) {
    var price = double.tryParse(value);
    if (price == null) {
      return 'Price must not be empty';
    } else if (price <= 0) {
      return 'Price must be greater than zero';
    } else {
      return null;
    }
  }

  String _validateDescription(value) {
    if (value.isEmpty) {
      return 'Description must not be empty';
    } else {
      return null;
    }
  }

  String _validateImageURL(value) {
    if (value.isEmpty) {
      return 'Image URL must not be empty';
    } else if (!value.startsWith('http')) {
      return 'Image URL must be a valid url';
    } else {
      return null;
    }
  }

  Future<void> _saveProductForm() async {
    if (_productFormGlobalKey.currentState.validate()) {
      _productFormGlobalKey.currentState.save();

      Products productsProvider = Provider.of<Products>(context, listen: false);

      setState(() {
        _isWaiting = true;
        _isEnabled = false;
      });

      try {
        if (_edittedProduct.id == null) {
          await productsProvider.addProduct(_edittedProduct);
        } else {
          await productsProvider.updateProduct(_edittedProduct);
        }

        _isSaved = true;

        Navigator.of(context).pop(true);
      } catch (error) {
        _scaffoldGlobalKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred while saving your product.',
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _saveProductForm,
            ),
          ),
        );

        setState(() {
          _isWaiting = false;
          _isEnabled = true;
        });
      }
    }
  }
}
