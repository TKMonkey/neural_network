import 'dart:async';

class CombineLatest<T1, T2, T> extends Stream<T> {
  T1? _latestValue1;
  T2? _latestValue2;
  final Function(T1 firstValue, T2 secondValue) _combine;

  final StreamController<T> _controller = StreamController<T>();

  CombineLatest(Stream<T1> stream1, Stream<T2> stream2, this._combine) {
    stream1.listen((value) {
      _latestValue1 = value;
      if (_latestValue2 != null) {
        _controller.add(_combine(_latestValue1!, _latestValue2!));
      }
    });

    stream2.listen((value) {
      _latestValue2 = value;
      if (_latestValue1 != null) {
        _controller.add(_combine(_latestValue1!, _latestValue2!));
      }
    });
  }
  @override
  StreamSubscription<T> listen(void Function(T event)? onData,
          {Function? onError, void Function()? onDone, bool? cancelOnError}) =>
      _controller.stream.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}
