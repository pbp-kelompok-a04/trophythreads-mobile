import 'package:flutter/material.dart';
import 'package:trophythreads_mobile/features/match_info/models/match_entry.dart';

class MatchEntryCard extends StatefulWidget {
  final MatchEntry match;
  final VoidCallback onTap;
  final bool isAdmin;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const MatchEntryCard({
    super.key,
    required this.match,
    required this.onTap,
    this.isAdmin = false,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<MatchEntryCard> createState() => _MatchEntryCardState();
}

class _MatchEntryCardState extends State<MatchEntryCard> {
  bool _isMenuOpen = false;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        elevation: (_isHovering) ? 4.0 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: const Color.fromARGB(255, 214, 214, 214),
            width: 0.5,
          ),
        ),
        color: Colors.white,
        child: Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: widget.onTap,
              onHover: (value) {
                setState(() {
                  _isHovering = value;
                });
              },
              hoverColor: const Color.fromARGB(7, 0, 0, 0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Text(
                        widget.match.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget.match.homeTeam.name,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                        SizedBox(width: 12.0),
                        // flag image home team
                        Container(
                          width: 33,
                          height: 22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.0),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: Image.network(
                              'http://localhost:8000/informasi/proxy-image/?url=${Uri.encodeComponent(widget.match.homeTeam.flag)}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        // skor
                        Text(
                          widget.match.scoreHome.toString(),
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          '-',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          widget.match.scoreAway.toString(),
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        // flag image away team
                        Container(
                          width: 33,
                          height: 22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.0),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2.0),
                            child: Image.network(
                              'http://localhost:8000/informasi/proxy-image/?url=${Uri.encodeComponent(widget.match.awayTeam.flag)}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.broken_image),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            widget.match.awayTeam.name,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (widget.match.isInfoHot)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "🔥 Hot",
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (widget.isAdmin)
              Positioned(
                top: 3,
                right: 3,
                child: Material(
                  color: const Color.fromARGB(0, 0, 0, 0),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300, width: 0.3),
                    ),
                    offset: const Offset(-10, 40),
                    menuPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    color: Colors.grey[200],
                    icon: Icon(
                      Icons.more_vert,
                      color: _isMenuOpen ? Colors.red : Colors.black,
                      size: 20,
                    ),
                    onOpened: () {
                      setState(() {
                        _isMenuOpen = true;
                      });
                    },
                    onCanceled: () {
                      setState(() {
                        _isMenuOpen = false;
                      });
                    },
                    onSelected: (value) async {
                      setState(() => _isMenuOpen = false);
                      if (value == 'delete') {
                        widget.onDelete?.call();
                      } else if (value == 'edit') {
                        widget.onEdit?.call();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            height: 35,
                            value: 'edit',
                            child: Text('Ubah'),
                          ),
                          PopupMenuDivider(
                            color: Colors.grey[300],
                            height: 0.1,
                          ),
                          const PopupMenuItem<String>(
                            height: 35,
                            value: 'delete',
                            child: Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
