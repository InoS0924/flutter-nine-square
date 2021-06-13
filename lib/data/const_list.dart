import 'package:flutter/material.dart';

// user data path
const users_collection_name = 'users';

// square data path
const root_collection_name = 'root_squares';
const trunk_collection_name = 'trunk_squares';
const leaf_collection_name = 'leaf_squares';

const max_depth = 2;
const num_child_square = 9;
const base_max_score = 100;

// parts
const EditPopupMenuItem = PopupMenuItem(
  value: 'Edit',
  child: ListTile(
    leading: Icon(Icons.edit),
    title: Text('Edit'),
  ),
);

const DetailPopupMenuItem = PopupMenuItem(
  value: 'Detail',
  child: ListTile(
    leading: Icon(Icons.read_more_rounded),
    title: Text('Detail'),
  ),
);

const DeletePopupMenuItem = PopupMenuItem(
  value: 'Delete',
  child: ListTile(
    leading: Icon(Icons.delete),
    title: Text('Delete'),
  ),
);

const DonePopupMenuItem = const PopupMenuItem(
  value: 'Done',
  child: ListTile(
    leading: Icon(Icons.done),
    title: Text('Done'),
  ),
);

const UndonePopupMenuItem = const PopupMenuItem(
  value: 'Undone',
  child: ListTile(
    leading: Icon(Icons.undo),
    title: Text('Undone'),
  ),
);

final ScoreDropdownMenuItem = [
  for (int i = 1; i <= 10; i++)
    DropdownMenuItem(
      child: Text('$i'),
      value: i,
    )
];
