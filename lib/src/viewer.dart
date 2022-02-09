import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';

/// enum to describe indicator position
enum IndicatorPosition {
  topLeft,
  topRight,
  topCenter,
  bottomLeft,
  bottomRight,
  bottomCenter,
}

/// PDFViewer, a inbuild pdf viewer, you can create your own too.
/// [document] an instance of `PDFDocument`, document to be loaded
/// [indicatorText] color of indicator text
/// [indicatorBackground] color of indicator background
/// [pickerButtonColor] the picker button background color
/// [pickerIconColor] the picker button icon color
/// [indicatorPosition] position of the indicator position defined by `IndicatorPosition` enum
/// [showIndicator] show,hide indicator
/// [showPicker] show hide picker
/// [showNavigation] show hide navigation bar
/// [toolTip] tooltip, instance of `PDFViewerTooltip`
/// [enableSwipeNavigation] enable,disable swipe navigation
/// [scrollDirection] scroll direction horizontal or vertical
/// [lazyLoad] lazy load pages or load all at once
/// [controller] page controller to control page viewer
/// [zoomSteps] zoom steps for pdf page
/// [minScale] minimum zoom scale for pdf page
/// [maxScale] maximum zoom scale for pdf page
/// [panLimit] pan limit for pdf page
/// [onPageChanged] function called when page changes
///
class PDFViewer extends StatefulWidget {
  const PDFViewer({
    Key? key,
    required this.document,
    this.scrollDirection,
    this.lazyLoad = true,
    this.indicatorText = Colors.white,
    this.indicatorBackground = Colors.black54,
    this.numberPickerConfirmWidget = const Text('OK'),
    this.showIndicator = true,
    this.showPicker = true,
    this.showNavigation = true,
    this.enableSwipeNavigation = true,
    this.tooltip = const PDFViewerTooltip(),
    this.navigationBuilder,
    this.controller,
    this.indicatorPosition = IndicatorPosition.topRight,
    this.zoomSteps,
    this.minScale,
    this.maxScale,
    this.panLimit,
    this.progressIndicator,
    this.pickerButtonColor,
    this.pickerIconColor,
    this.onPageChanged,
    this.backgroundColor,
    this.indicatorBuilder,
  }) : super(key: key);

  final PDFDocument document;
  final Color indicatorText;
  final Color indicatorBackground;
  final Color? pickerButtonColor;
  final Color? pickerIconColor;
  final IndicatorPosition indicatorPosition;
  final Widget numberPickerConfirmWidget;
  final bool showIndicator;
  final bool showPicker;
  final bool showNavigation;
  final PDFViewerTooltip tooltip;
  final bool enableSwipeNavigation;
  final Axis? scrollDirection;
  final bool lazyLoad;
  final PageController? controller;
  final int? zoomSteps;
  final double? minScale;
  final double? maxScale;
  final double? panLimit;
  final ValueChanged<int>? onPageChanged;
  final Color? backgroundColor;
  final Widget Function(BuildContext, int? pageNumber, int? totalPages)?
      indicatorBuilder;

  final Widget Function(
    BuildContext,
    int? pageNumber,
    int? totalPages,
    void Function({int page}) jumpToPage,
    void Function({int? page}) animateToPage,
  )? navigationBuilder;
  final Widget? progressIndicator;

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  bool _isLoading = true;
  late int _pageNumber;
  bool _swipeEnabled = true;
  List<PDFPage?>? _pages;
  late PageController _pageController;
  final animationDuration = const Duration(milliseconds: 200);
  final animationCurve = Curves.easeIn;
  bool _showTextField = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _pages = List.filled(widget.document.count, null);
    _pageController = widget.controller ?? PageController();
    _pageNumber = _pageController.initialPage + 1;
    if (!widget.lazyLoad) _preloadPages();
  }

  @override
  void didUpdateWidget(PDFViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_showTextField && widget.showIndicator) {
      setState(() => _showTextField = false);
    }
    if (oldWidget.document.filePath != widget.document.filePath) {
      _initialize();
      _isLoading = true;
      _loadPage();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialize();
    _isLoading = true;

    _loadPage();
  }

  Future<void> _preloadPages() async {
    var countvar = 1;
    for (final _ in List.filled(widget.document.count, null)) {
      final data = await widget.document.get(
        page: countvar,
        onZoomChanged: onZoomChanged,
        zoomSteps: widget.zoomSteps,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        panLimit: widget.panLimit,
      );
      _pages![countvar - 1] = data;

      countvar++;
    }
  }

  void onZoomChanged(double scale) {
    setState(() => _swipeEnabled = scale == 1.0);
  }

  Future<void> _loadPage() async {
    if (_pages![_pageNumber - 1] != null) return;
    setState(() => _isLoading = true);
    final data = await widget.document.get(
      page: _pageNumber,
      onZoomChanged: onZoomChanged,
      zoomSteps: widget.zoomSteps,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      panLimit: widget.panLimit,
    );
    _pages![_pageNumber - 1] = data;
    if (mounted) setState(() => _isLoading = false);
  }

  void _animateToPage({int? page}) {
    _pageController.animateToPage(
      page ?? _pageNumber - 1,
      duration: animationDuration,
      curve: animationCurve,
    );
  }

  void _jumpToPage({int? page}) {
    _pageController.jumpToPage(page ?? _pageNumber - 1);
  }

  Widget _drawIndicator() {
    if (widget.indicatorBuilder != null) {
      return widget.indicatorBuilder!(
        context,
        _pageNumber,
        widget.document.count,
      );
    }

    final child = GestureDetector(
      onTap: () {
        if (widget.showPicker && widget.document.count > 1) {
          setState(() => _showTextField = true);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 16.0,
            ),
            height: 30,
            width: _showTextField ? 80 : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: widget.indicatorBackground,
            ),
            child: _showTextField
                ? TextFormField(
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    maxLength: 3,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      counterText: '',
                      hintText: '$_pageNumber/${widget.document.count}',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: TextStyle(
                      color: widget.indicatorText,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    onFieldSubmitted: _onSubmit,
                  )
                : Text(
                    '$_pageNumber/${widget.document.count}',
                    style: TextStyle(
                      color: widget.indicatorText,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
        ],
      ),
    );

    switch (widget.indicatorPosition) {
      case IndicatorPosition.topLeft:
        return Positioned(top: 20, left: 20, child: child);
      case IndicatorPosition.topRight:
        return Positioned(top: 20, right: 20, child: child);
      case IndicatorPosition.bottomLeft:
        return Positioned(bottom: 20, left: 20, child: child);
      case IndicatorPosition.bottomRight:
        return Positioned(bottom: 20, right: 20, child: child);
      case IndicatorPosition.bottomCenter:
        return Positioned(bottom: 20, right: 0, left: 0, child: child);
      case IndicatorPosition.topCenter:
        return Positioned(top: 20, right: 0, left: 0, child: child);
      default:
        return Positioned(top: 20, right: 20, child: child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: <Widget>[
          PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (page) {
              setState(() => _pageNumber = page + 1);
              _loadPage();
              widget.onPageChanged?.call(page);
            },
            scrollDirection: widget.scrollDirection ?? Axis.horizontal,
            controller: _pageController,
            itemCount: _pages?.length ?? 0,
            itemBuilder: (_, index) => _pages![index] == null
                ? Center(
                    child: widget.progressIndicator ??
                        const CircularProgressIndicator.adaptive(),
                  )
                : _pages![index]!,
          ),
          if (widget.showIndicator && !_isLoading)
            _drawIndicator()
          else
            const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: (widget.showNavigation && widget.document.count > 1)
          ? widget.navigationBuilder != null
              ? widget.navigationBuilder!(
                  context,
                  _pageNumber,
                  widget.document.count,
                  _jumpToPage,
                  _animateToPage,
                )
              : BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.first_page),
                          tooltip: widget.tooltip.first,
                          onPressed: _pageNumber == 1 || _isLoading
                              ? null
                              : () {
                                  _pageNumber = 1;
                                  _jumpToPage();
                                },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left),
                          tooltip: widget.tooltip.previous,
                          onPressed: _pageNumber == 1 || _isLoading
                              ? null
                              : () {
                                  _pageNumber--;
                                  if (1 > _pageNumber) {
                                    _pageNumber = 1;
                                  }
                                  _animateToPage();
                                },
                        ),
                      ),
                      if (widget.showPicker) const Spacer(),
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right),
                          tooltip: widget.tooltip.next,
                          onPressed:
                              _pageNumber == widget.document.count || _isLoading
                                  ? null
                                  : () {
                                      _pageNumber++;
                                      if (widget.document.count < _pageNumber) {
                                        _pageNumber = widget.document.count;
                                      }
                                      _animateToPage();
                                    },
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.last_page),
                          tooltip: widget.tooltip.last,
                          onPressed:
                              _pageNumber == widget.document.count || _isLoading
                                  ? null
                                  : () {
                                      _pageNumber = widget.document.count;
                                      _jumpToPage();
                                    },
                        ),
                      ),
                    ],
                  ),
                )
          : const SizedBox.shrink(),
    );
  }

  void _onSubmit(String? value) {
    if (value != null && isNumericUsingRegularExpression(value)) {
      final _page = int.parse(value);
      _pageNumber =
          _page > widget.document.count ? widget.document.count : _page;
      _jumpToPage();
    }
    setState(() => _showTextField = false);
  }

  bool isNumericUsingRegularExpression(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');

    return numericRegex.hasMatch(string);
  }
}
