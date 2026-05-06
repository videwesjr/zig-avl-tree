const std = @import("std");

pub fn AVLTree(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            value: T,
            height: i32,
            left: ?*Node,
            right: ?*Node,
        };

        allocator: std.mem.Allocator,
        root: ?*Node,
        size: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .allocator = allocator,
                .root = null,
                .size = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.free(self.root);
        }

        fn free(self: *Self, node: ?*Node) void {
            if (node) |n| {
                self.free(n.left);
                self.free(n.right);
                self.allocator.destroy(n);
            }
        }

        fn h(n: ?*Node) i32 {
            return if (n) |x| x.height else 0;
        }

        fn update(n: *Node) void {
            n.height = 1 + @max(h(n.left), h(n.right));
        }

        fn rotateRight(y: *Node) *Node {
            const x = y.left.?;
            y.left = x.right;
            x.right = y;
            update(y);
            update(x);
            return x;
        }

        fn rotateLeft(x: *Node) *Node {
            const y = x.right.?;
            x.right = y.left;
            y.left = x;
            update(x);
            update(y);
            return y;
        }

        fn balance(n: *Node) *Node {
            update(n);
            const bf = h(n.left) - h(n.right);

            if (bf > 1) {
                if (h(n.left.?.right) > h(n.left.?.left))
                    n.left = rotateLeft(n.left.?);
                return rotateRight(n);
            }

            if (bf < -1) {
                if (h(n.right.?.left) > h(n.right.?.right))
                    n.right = rotateRight(n.right.?);
                return rotateLeft(n);
            }

            return n;
        }

        pub fn insert(self: *Self, value: T) !void {
            var added = false;
            self.root = try self._insert(self.root, value, &added);
            if (added) self.size += 1;
        }

        fn _insert(self: *Self, node: ?*Node, value: T, added: *bool) !*Node {
            if (node == null) {
                const n = try self.allocator.create(Node);
                n.* = .{
                    .value = value,
                    .height = 1,
                    .left = null,
                    .right = null,
                };
                added.* = true;
                return n;
            }

            const n = node.?;

            if (value < n.value) {
                n.left = try self._insert(n.left, value, added);
            } else if (value > n.value) {
                n.right = try self._insert(n.right, value, added);
            }

            return balance(n);
        }

        pub fn delete(self: *Self, value: T) void {
            var removed = false;
            self.root = self._delete(self.root, value, &removed);
            if (removed) self.size -= 1;
        }

        fn _delete(self: *Self, node: ?*Node, value: T, removed: *bool) ?*Node {
            const n = node orelse return null;

            if (value < n.value) {
                n.left = self._delete(n.left, value, removed);
            } else if (value > n.value) {
                n.right = self._delete(n.right, value, removed);
            } else {
                removed.* = true;

                if (n.left == null) {
                    const r = n.right;
                    self.allocator.destroy(n);
                    return r;
                }

                if (n.right == null) {
                    const l = n.left;
                    self.allocator.destroy(n);
                    return l;
                }

                var s = n.right.?;
                while (s.left) |l| s = l;

                n.value = s.value;
                var dummy = false;
                n.right = self._delete(n.right, s.value, &dummy);
            }

            return balance(n);
        }

        pub fn contains(self: *Self, value: T) bool {
            var cur = self.root;
            while (cur) |n| {
                if (value == n.value) return true;
                cur = if (value < n.value) n.left else n.right;
            }
            return false;
        }

        pub fn inorder(self: *Self) !void {
            try inorderNode(self.root);
            std.debug.print("\n", .{});
        }

        fn inorderNode(n: ?*Node) !void {
            if (n) |x| {
                try inorderNode(x.left);
                std.debug.print("{} ", .{x.value});
                try inorderNode(x.right);
            }
        }

        pub fn levels(self: *Self) i32 {
            return h(self.root);
        }

        pub fn printTree(self: *Self) !void {
            try printNode(self.root, 0, true);
        }

        fn printNode(node: ?*Node, depth: usize, is_last: bool) !void {
            if (node) |n| {
                var i: usize = 0;
                while (i < depth) : (i += 1) {
                    std.debug.print("    ", .{});
                }

                std.debug.print("{s}{} (h={})\n", .{
                    if (is_last) "└── " else "├── ",
                    n.value,
                    n.height,
                });

                const has_left = n.left != null;
                const has_right = n.right != null;

                if (has_left)
                    try printNode(n.left, depth + 1, !has_right);

                if (has_right)
                    try printNode(n.right, depth + 1, true);
            }
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var tree = AVLTree(i32).init(allocator);
    defer tree.deinit();

    const values = [_]i32{ 10, 20, 30, 40, 50, 25 };

    std.debug.print("Inserting:\n", .{});
    for (values) |v| {
        std.debug.print("{} ", .{v});
        try tree.insert(v);
    }

    std.debug.print("\n\nSize: {}\n", .{tree.size});
    std.debug.print("Levels: {}\n\n", .{tree.levels()});

    std.debug.print("\nTree structure:\n", .{});
    try tree.printTree();
    
    std.debug.print("In-order: ", .{});
    try tree.inorder();

    std.debug.print("\nContains 25? {}\n", .{tree.contains(25)});
    std.debug.print("Contains 99? {}\n", .{tree.contains(99)});

    std.debug.print("\nDeleting 20...\n", .{});
    tree.delete(20);

    std.debug.print("Size: {}\n", .{tree.size});
    std.debug.print("Levels: {}\n", .{tree.levels()});

    std.debug.print("In-order: ", .{});
    try tree.inorder();

    std.debug.print("\nTree structure:\n", .{});
    try tree.printTree();
}
