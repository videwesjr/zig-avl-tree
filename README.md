# AVL Tree in Zig

A implementation of an **AVL Tree** in Zig https://zig.guide.

---

## Features

* Self-balancing binary search tree (AVL)
* Generic implementation (`comptime T`)
* Operations:

  * Insert
  * Delete
  * Search (`contains`)
* Tree traversal:

  * In-order (sorted output)
* Tree visualization:

  * Pretty printed structure (ASCII / Unicode)
* Height tracking (AVL invariant)
* Memory-safe using allocator

---

## Requirements

* Zig **0.16.0** or newer

Check your version:

```bash
zig version
```

---

## How to Run

```bash
zig run main.zig
```

---

## Example Output

```text
Inserting:
10 20 30 40 50 25 

Size: 6
Levels: 3

In-order: 10 20 25 30 40 50 

Contains 25? true
Contains 99? false

Deleting 20...
Size: 5
Levels: 3
In-order: 10 25 30 40 50
```

---

## How It Works

* The AVL tree keeps itself balanced after each insert and delete.
* Each node stores its height.
* The balance factor (left height - right height) determines if rotations are needed.
* Rotations (left, right, or double) restore balance.
* This guarantees **O(log n)** performance for all operations.
