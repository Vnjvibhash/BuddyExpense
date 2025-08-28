import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buddyexpense/models/user_profile.dart';
import 'package:buddyexpense/models/group.dart';
import 'package:buddyexpense/models/expense.dart';
import 'package:buddyexpense/models/settlement.dart';

class AppState extends ChangeNotifier {
  static const _kUsers = 'users';
  static const _kGroups = 'groups';
  static const _kExpenses = 'expenses';
  static const _kSettlements = 'settlements';

  final List<UserProfileModel> _users = [];
  final List<GroupModel> _groups = [];
  final List<ExpenseModel> _expenses = [];
  final List<SettlementModel> _settlements = [];

  bool _loaded = false;
  bool get loaded => _loaded;

  List<UserProfileModel> get users => List.unmodifiable(_users);
  List<GroupModel> get groups => List.unmodifiable(_groups);
  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);
  List<SettlementModel> get settlements => List.unmodifiable(_settlements);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final usersStr = prefs.getString(_kUsers);
    final groupsStr = prefs.getString(_kGroups);
    final expensesStr = prefs.getString(_kExpenses);
    final settlementsStr = prefs.getString(_kSettlements);

    if (usersStr == null || groupsStr == null) {
      _seedSampleData();
      await _persist();
    } else {
      _users
        ..clear()
        ..addAll(UserProfileModel.listFromJsonString(usersStr));
      _groups
        ..clear()
        ..addAll(GroupModel.listFromJsonString(groupsStr));
      if (expensesStr != null) {
        _expenses
          ..clear()
          ..addAll(ExpenseModel.listFromJsonString(expensesStr));
      }
      if (settlementsStr != null) {
        _settlements
          ..clear()
          ..addAll(SettlementModel.listFromJsonString(settlementsStr));
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsers, UserProfileModel.listToJsonString(_users));
    await prefs.setString(_kGroups, GroupModel.listToJsonString(_groups));
    await prefs.setString(_kExpenses, ExpenseModel.listToJsonString(_expenses));
    await prefs.setString(
      _kSettlements,
      SettlementModel.listToJsonString(_settlements),
    );
  }

  // CRUD operations
  void addUser(UserProfileModel user) {
    _users.add(user);
    _persist();
    notifyListeners();
  }

  void addGroup(GroupModel group) {
    _groups.add(group);
    _persist();
    notifyListeners();
  }

  void updateGroup(GroupModel group) {
    final idx = _groups.indexWhere((g) => g.id == group.id);
    if (idx != -1) _groups[idx] = group;
    _persist();
    notifyListeners();
  }

  void deleteGroup(String groupId) {
    _groups.removeWhere((g) => g.id == groupId);
    _expenses.removeWhere((e) => e.groupId == groupId);
    _settlements.removeWhere((s) => s.groupId == groupId);
    _persist();
    notifyListeners();
  }

  void addExpense(ExpenseModel expense) {
    _expenses.add(expense);
    _persist();
    notifyListeners();
  }

  void deleteExpense(String expenseId) {
    _expenses.removeWhere((e) => e.id == expenseId);
    _persist();
    notifyListeners();
  }

  void addSettlement(SettlementModel settlement) {
    _settlements.add(settlement);
    _persist();
    notifyListeners();
  }

  Map<String, double> balancesForGroup(String groupId) {
    final group = _groups.firstWhere((g) => g.id == groupId);
    final Map<String, double> balance = {
      for (final id in group.memberUserIds) id: 0,
    };

    for (final e in _expenses.where((e) => e.groupId == groupId)) {
      // payer gets credit
      balance[e.paidByUserId] = (balance[e.paidByUserId] ?? 0) + e.amount;
      // everyone owes their share
      e.shares.forEach((userId, share) {
        balance[userId] = (balance[userId] ?? 0) - share;
      });
    }

    for (final s in _settlements.where((s) => s.groupId == groupId)) {
      balance[s.fromUserId] = (balance[s.fromUserId] ?? 0) - s.amount;
      balance[s.toUserId] = (balance[s.toUserId] ?? 0) + s.amount;
    }

    return balance;
  }

  void _seedSampleData() {
    _users
      ..clear()
      ..addAll(const [
        UserProfileModel(id: 'u_alex', name: 'Alex', avatarEmoji: '🦊'),
        UserProfileModel(id: 'u_bailey', name: 'Bailey', avatarEmoji: '🐼'),
        UserProfileModel(id: 'u_casey', name: 'Casey', avatarEmoji: '🦁'),
        UserProfileModel(id: 'u_drew', name: 'Drew', avatarEmoji: '🐧'),
      ]);

    _groups
      ..clear()
      ..addAll(const [
        GroupModel(
          id: 'g_trip',
          name: 'Euro Trip',
          memberUserIds: ['u_alex', 'u_bailey', 'u_casey'],
          currency: 'EUR',
        ),
        GroupModel(
          id: 'g_home',
          name: 'Roommates',
          memberUserIds: ['u_alex', 'u_bailey', 'u_drew'],
          currency: 'USD',
        ),
      ]);

    _expenses
      ..clear()
      ..addAll([
        ExpenseModel(
          id: 'e1',
          groupId: 'g_trip',
          paidByUserId: 'u_alex',
          description: 'Dinner in Rome',
          amount: 84.0,
          createdAt: DateTime.now().subtract(const Duration(days: 6)),
          shares: {'u_alex': 28.0, 'u_bailey': 28.0, 'u_casey': 28.0},
          currency: 'EUR',
        ),
        ExpenseModel(
          id: 'e2',
          groupId: 'g_home',
          paidByUserId: 'u_bailey',
          description: 'Groceries',
          amount: 120.0,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          shares: {'u_alex': 40.0, 'u_bailey': 40.0, 'u_drew': 40.0},
          currency: 'USD',
        ),
      ]);

    _settlements
      ..clear()
      ..addAll([
        SettlementModel(
          id: 's1',
          groupId: 'g_home',
          fromUserId: 'u_alex',
          toUserId: 'u_bailey',
          amount: 20,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
  }

  UserProfileModel? userById(String id) =>
      _users.where((u) => u.id == id).cast<UserProfileModel?>().firstOrNull;
}

extension FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
