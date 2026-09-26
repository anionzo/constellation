import 'dart:async';
import 'package:flutter/material.dart';
import '../../features/photo_upload/models/friend_chip.dart';
import '../../features/photo_upload/models/photo_upload_input.dart';
import '../../features/photo_upload/machine/photo_upload_state_machine.dart';
import '../../features/photo_upload/state/photo_upload_state.dart';
import '../../features/photo_upload/state/photo_upload_event.dart';
import '../theme/quire_tokens.dart';

/// Quire Compose Sheet Widget.
/// Enforces: >= 1 friend selection, button locking, and 900ms Undo window.
class QuireComposeSheet extends StatefulWidget {
  final PhotoUploadInput input;
  final List<FriendChip> availableFriends;
  final PhotoUploadStateMachine stateMachine;
  final VoidCallback onClose;
  final void Function(String message) onShowToast;

  const QuireComposeSheet({
    Key? key,
    required this.input,
    required this.availableFriends,
    required this.stateMachine,
    required this.onClose,
    required this.onShowToast,
  }) : super(key: key);

  @override
  State<QuireComposeSheet> createState() => _QuireComposeSheetState();
}

class _QuireComposeSheetState extends State<QuireComposeSheet> {
  final TextEditingController _noteController = TextEditingController();
  final Set<String> _selectedFriends = {};
  late StreamSubscription<PhotoUploadState> _subscription;
  PhotoUploadState _currentState = const PhotoUploadIdleState();
  Timer? _undoTimer;
  double _undoProgress = 1.0;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stateMachine.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _currentState = state;
        });

        if (state is PhotoUploadUndoGraceState) {
          _startUndoAnimation();
        } else if (state is PhotoUploadAbortedState) {
          widget.onShowToast('Đã huỷ gửi. Không có gì rời khỏi ứng dụng.');
          widget.onClose();
        } else if (state is PhotoUploadDispatchedState) {
          widget.onClose();
        }
      }
    });

    widget.stateMachine.startComposeWithPhoto(
      photo: widget.input.toRawPhotoFile(),
      context: const PhotoUploadContext(circleId: 'default-circle-id'),
    );
  }

  void _startUndoAnimation() {
    const totalDuration = Duration(milliseconds: 900);
    const interval = Duration(milliseconds: 30);
    int elapsed = 0;

    _undoTimer = Timer.periodic(interval, (timer) {
      elapsed += 30;
      if (mounted) {
        setState(() {
          _undoProgress = 1.0 - (elapsed / totalDuration.inMilliseconds);
        });
      }
      if (elapsed >= totalDuration.inMilliseconds) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _subscription.cancel();
    _undoTimer?.cancel();
    super.dispose();
  }

  void _toggleFriend(String id) {
    setState(() {
      if (_selectedFriends.contains(id)) {
        _selectedFriends.remove(id);
      } else {
        _selectedFriends.add(id);
      }
    });
    widget.stateMachine.toggleFriend(id);
  }

  @override
  Widget build(BuildContext context) {
    final isDoneView = _currentState is PhotoUploadUndoGraceState;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
      decoration: const BoxDecoration(
        color: QuireTokens.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(QuireTokens.rSheet)),
        border: Border(top: BorderSide(color: QuireTokens.ruleLight, width: 1.0)),
      ),
      child: SafeArea(
        top: false,
        child: isDoneView ? _buildDoneContent() : _buildComposeContent(),
      ),
    );
  }

  Widget _buildComposeContent() {
    final isSending = _currentState is PhotoUploadSendingState;
    final canSend = _selectedFriends.isNotEmpty && !isSending;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Chia sẻ khoảnh khắc', style: QuireTokens.h3()),
            IconButton(
              icon: const Icon(Icons.close, size: 20, color: QuireTokens.ink2Light),
              onPressed: widget.onClose,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Thumbnail & Caption Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(QuireTokens.rPhoto),
              child: Container(
                width: 72,
                height: 72,
                color: QuireTokens.s2Light,
                child: Image.memory(
                  widget.input.rawBytes,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image, color: QuireTokens.ink3Light),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: _noteController,
                style: QuireTokens.body(),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Thêm lời nhắn (tuỳ chọn)...',
                  hintStyle: TextStyle(fontFamily: QuireTokens.fontSerif, color: QuireTokens.ink3Light),
                  border: InputBorder.none,
                ),
                onChanged: (text) => widget.stateMachine.updateCaption(text),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('GỬI ĐẾN AI', style: QuireTokens.eyebrow()),
        const SizedBox(height: 10),
        // Friend Chips Selector (Finite Circle 4-11 friends)
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.availableFriends.map((friend) {
            final isSelected = _selectedFriends.contains(friend.id);
            return FilterChip(
              label: Text(friend.name),
              selected: isSelected,
              onSelected: isSending ? null : (_) => _toggleFriend(friend.id),
              backgroundColor: QuireTokens.paperLight,
              selectedColor: QuireTokens.accentSoftLight,
              checkmarkColor: QuireTokens.accentInkLight,
              labelStyle: TextStyle(
                fontFamily: QuireTokens.fontSerif,
                fontSize: 13.0,
                color: isSelected ? QuireTokens.accentInkLight : QuireTokens.inkLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: isSelected ? QuireTokens.accentLight : QuireTokens.ruleLight,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Send Button (Locked immediately upon click)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: QuireTokens.accentLight,
            disabledBackgroundColor: QuireTokens.ruleLight,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(QuireTokens.rBtn),
            ),
            elevation: 0,
          ),
          onPressed: canSend
              ? () {
                  widget.stateMachine.submitSend();
                }
              : null,
          child: Text(
            isSending
                ? 'Đang gửi…'
                : _selectedFriends.isEmpty
                    ? 'Chọn ít nhất một người'
                    : 'Gửi cho ${_selectedFriends.length} người',
            style: TextStyle(
              fontFamily: QuireTokens.fontSerif,
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: canSend ? Colors.white : QuireTokens.ink3Light,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoneContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Text('Đã gửi cho ${_selectedFriends.length} người', style: QuireTokens.title()),
        const SizedBox(height: 8),
        Text(
          'Họ có thể thả tim, đáp lại bằng ảnh, hoặc giữ riêng.',
          textAlign: TextAlign.center,
          style: QuireTokens.body(),
        ),
        const SizedBox(height: 18),
        // Linear Progress Bar for 900ms Undo Window
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: _undoProgress.clamp(0.0, 1.0),
            backgroundColor: QuireTokens.ruleLight,
            color: QuireTokens.accentLight,
            minHeight: 3,
          ),
        ),
        const SizedBox(height: 20),
        // Prominent Undo Button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: QuireTokens.rule2Light),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(QuireTokens.rBtn),
            ),
          ),
          onPressed: () {
            _undoTimer?.cancel();
            widget.stateMachine.triggerUndo();
          },
          child: Text(
            'Hoàn tác',
            style: QuireTokens.body().copyWith(color: QuireTokens.inkLight, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
