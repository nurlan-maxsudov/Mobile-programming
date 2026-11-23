import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/classification_record.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/model_screen.dart';
import 'screens/result_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/classifier.dart';
import 'services/image_sources.dart';
import 'theme/app_theme.dart';
import 'widgets/image_url_dialog.dart';

class ClassifierApp extends StatefulWidget {
  const ClassifierApp({
    super.key,
    this.classifierLoader = Classifier.load,
    this.sampleLoader = loadSample,
    this.imageSources,
  });

  final Future<Classifier> Function() classifierLoader;
  final Future<Uint8List> Function() sampleLoader;
  final ImageSources? imageSources;
  static const sampleAsset = 'assets/model/sample.jpeg';

  static Future<Uint8List> loadSample() async {
    try {
      final data = await rootBundle.load(sampleAsset);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (error) {
      throw ClassifierException('Could not load "$sampleAsset". $error');
    }
  }

  @override
  State<ClassifierApp> createState() => _ClassifierAppState();
}

class _ClassifierAppState extends State<ClassifierApp> {
  final _navigator = GlobalKey<NavigatorState>();
  final _history = <ClassificationRecord>[];
  late final ImageSources _sources;
  Classifier? _classifier;
  String? _loadError, _imageError, _status;
  bool _busy = false;
  bool _started = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _sources = widget.imageSources ?? ImageSources();
    _loadClassifier();
  }

  Future<void> _loadClassifier() async {
    setState(() => _loadError = null);
    try {
      final classifier = await widget.classifierLoader();
      if (!mounted) {
        classifier.close();
        return;
      }
      setState(() => _classifier = classifier);
    } catch (error) {
      if (mounted) setState(() => _loadError = error.toString());
    }
  }

  Future<void> _classify(
    Future<Uint8List?> Function() obtainBytes,
    ImageOrigin source,
  ) async {
    final classifier = _classifier;
    if (classifier == null || _busy) return;
    setState(() {
      _busy = true;
      _imageError = null;
      _status = switch (source) {
        ImageOrigin.camera => 'Opening camera…',
        ImageOrigin.gallery => 'Opening gallery…',
        ImageOrigin.download => 'Downloading image…',
        ImageOrigin.sample => 'Loading sample…',
      };
    });
    try {
      final bytes = await obtainBytes();
      // Cancelling the system picker is not an error and adds no History entry.
      if (!mounted || bytes == null) return;
      setState(() => _status = 'Classifying photo…');
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final stopwatch = Stopwatch()..start();
      final predictions = classifier.classify(bytes);
      stopwatch.stop();
      for (final prediction in predictions) {
        debugPrint(
          '${prediction.label}: ${(prediction.confidence * 100).toStringAsFixed(1)}%',
        );
      }
      final total = predictions.fold(0.0, (sum, p) => sum + p.confidence);
      debugPrint(
        '${source.label}: ${predictions.length} labels; sum=${total.toStringAsFixed(6)}; top=${predictions.first.label}; time=${stopwatch.elapsedMilliseconds} ms',
      );
      final record = ClassificationRecord(
        bytes: bytes,
        predictions: predictions,
        source: source,
        duration: stopwatch.elapsed,
      );
      setState(() => _history.insert(0, record));
      _openResult(record);
    } catch (error) {
      if (mounted) setState(() => _imageError = error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = null;
        });
      }
    }
  }

  void _openResult(ClassificationRecord record) {
    _navigator.currentState!.push<void>(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          imageBytes: record.bytes,
          predictions: record.predictions,
          source: record.source.label,
          duration: record.duration,
        ),
      ),
    );
  }

  Future<void> _download() async {
    if (_busy) return;
    final url = await showDialog<String>(
      context: _navigator.currentContext!,
      builder: (_) => const ImageUrlDialog(),
    );
    if (mounted && url != null) {
      await _classify(() => _sources.fromUrl(url), ImageOrigin.download);
    }
  }

  @override
  void dispose() {
    _classifier?.close();
    _sources.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classifier = _classifier;
    return MaterialApp(
      navigatorKey: _navigator,
      title: 'Image Classifier',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: !_started || classifier == null
          ? WelcomeScreen(
              labels: classifier?.labels,
              loadError: _loadError,
              sampleError: _imageError,
              busy: _busy,
              onRetry: _loadClassifier,
              onGetStarted: () => setState(() => _started = true),
              onClassifySample: () =>
                  _classify(widget.sampleLoader, ImageOrigin.sample),
            )
          : PopScope(
              canPop: _tab == 0,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) setState(() => _tab = 0);
              },
              child: Scaffold(
                appBar: AppBar(title: Text(['Home', 'History', 'Model'][_tab])),
                body: SafeArea(
                  child: switch (_tab) {
                    1 => HistoryScreen(records: _history, onOpen: _openResult),
                    2 => ModelScreen(labels: classifier.labels),
                    _ => HomeScreen(
                      busy: _busy,
                      status: _status,
                      error: _imageError,
                      latest: _history.isEmpty ? null : _history.first,
                      onCamera: () =>
                          _classify(_sources.fromCamera, ImageOrigin.camera),
                      onGallery: () =>
                          _classify(_sources.fromGallery, ImageOrigin.gallery),
                      onDownload: _download,
                      onSample: () =>
                          _classify(widget.sampleLoader, ImageOrigin.sample),
                      onOpenLatest: () => _openResult(_history.first),
                    ),
                  },
                ),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: _tab,
                  onDestinationSelected: _busy
                      ? null
                      : (tab) => setState(() => _tab = tab),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.history),
                      label: 'History',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.info_outline),
                      label: 'Model',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
