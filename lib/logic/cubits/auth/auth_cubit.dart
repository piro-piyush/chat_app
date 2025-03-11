import 'dart:async';

import 'package:chat_app/data/repositories/auth_repository.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubits/auth/auth_state.dart';
import 'package:chat_app/presentation/auth/login_screen.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  StreamSubscription<User?>? _userSubscription;

  AuthCubit({required AuthRepository repo})
    : _repo = repo,
      super(const AuthState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(status: AuthStatus.loading));
    _userSubscription = _repo.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          final userModel = await _repo.getUserData(user.uid);
          emit(
            state.copyWith(status: AuthStatus.authenticated, user: userModel),
          );
        } catch (e) {
          emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
        }
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final userData = await _repo.signIn(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: userData));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }


  Future<void> signUp({
    required String email, required String password,
    required String fullName, required String username,
    required String phoneNumber,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final userData = await _repo.signUp(username: username, email: email, fullName: fullName, phoneNumber: phoneNumber, password: password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: userData));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }


  Future<void> signOut(
  ) async {
    try {
      await _repo.signOut();
      emit(state.copyWith(status: AuthStatus.unauthenticated,user: null));
      getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }
}
