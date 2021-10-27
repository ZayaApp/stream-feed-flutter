import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_feed/stream_feed.dart';

//TODO: find a better than shift

// extension AlreadyReacted on Reaction {
//   bool alreadyReactedTo(String kind) {
//     final ownReactions = ownChildren?[kind];
//     return ownReactions != null && ownReactions.isNotEmpty;
//   }
// }

// extension AlreadyReactedEnrichedActivity on EnrichedActivity {
//   bool alreadyReactedTo(String kind) {
//     final _ownReactions = ownReactions?[kind];
//     return _ownReactions != null && _ownReactions.isNotEmpty;
//   }
// }

extension ReactionX on List<Reaction> {
  ///Filter reactions by reaction kind
  List<Reaction?> filterByKind(String kind) =>
      where((reaction) => reaction.kind == kind).toList();

  Reaction getReactionPath(Reaction reaction) =>
      firstWhere((r) => r.id! == reaction.id!); //TODO; handle doesn't exist
}

extension EnrichedActivityX<A, Ob, T, Or>
    on List<GenericEnrichedActivity<A, Ob, T, Or>> {
  GenericEnrichedActivity<A, Ob, T, Or> getEnrichedActivityPath(
          GenericEnrichedActivity<A, Ob, T, Or> enrichedActivity) =>
      firstWhere(
          (e) => e.id! == enrichedActivity.id!); //TODO; handle doesn't exist

}

extension UpdateIn<A, Ob, T, Or>
    on List<GenericEnrichedActivity<A, Ob, T, Or>> {
  List<GenericEnrichedActivity<A, Ob, T, Or>> updateIn(
      GenericEnrichedActivity<A, Ob, T, Or> enrichedActivity, int indexPath) {
    var result = List<GenericEnrichedActivity<A, Ob, T, Or>>.from(this);
    result.isNotEmpty
        ? result.removeAt(indexPath) //removes the item at index 1
        : null;
    result.insert(indexPath, enrichedActivity);
    return result;
  }
}

extension UpdateInReaction on List<Reaction> {
  List<Reaction> updateIn(Reaction enrichedActivity, int indexPath) {
    var result = List<Reaction>.from(this);
    result.isNotEmpty
        ? result.removeAt(indexPath) //removes the item at index 1
        : null;
    result.insert(indexPath, enrichedActivity);
    return result;
  }
}

extension UnshiftMapList on Map<String, List<Reaction>>? {
  //TODO: maybe refactor to an operator maybe [Reaction] + Reaction
  Map<String, List<Reaction>> unshiftByKind(String kind, Reaction reaction,
      [ShiftType type = ShiftType.increment]) {
    Map<String, List<Reaction>>? result;
    result = this;
    final latestReactionsByKind = this?[kind] ?? [];
    if (result != null) {
      result = {...result, kind: latestReactionsByKind.unshift(reaction, type)};
    } else {
      result = {
        //TODO: handle decrement: should we throw?
        kind: [reaction]
      };
    }
    return result;
  }
}

@visibleForTesting
extension UnshiftMapController
    on Map<String, BehaviorSubject<List<Reaction>>>? {
  ///Lookup latest Reactions by Id and inserts the given reaction to the beginning of the list
  Map<String, BehaviorSubject<List<Reaction>>> unshiftById(
      String activityId, Reaction reaction,
      [ShiftType type = ShiftType.increment]) {
    Map<String, BehaviorSubject<List<Reaction>>>? result;
    result = this;
    final latestReactionsById = this?[activityId]?.valueOrNull ?? [];
    if (result != null && result[activityId] != null) {
      result[activityId]!.add(latestReactionsById.unshift(reaction, type));
    } else {
      result = {
        //TODO: handle decrement
        activityId: BehaviorSubject.seeded([reaction])
      };
    }
    return result;
  }
}

//TODO: find a better name
enum ShiftType { increment, decrement }

extension UnshiftMapInt on Map<String, int>? {
  Map<String, int> unshiftByKind(String kind,
      [ShiftType type = ShiftType.increment]) {
    Map<String, int>? result;
    result = this;
    final reactionCountsByKind = result?[kind] ?? 0;
    if (result != null) {
      result = {
        ...result,
        kind: reactionCountsByKind.unshift(type)
      }; //+1 if increment else -1
    } else {
      if (type == ShiftType.increment) {
        result = {kind: 1};
      } else {
        result = {kind: 0};
      }
    }
    return result;
  }
}

extension Unshift<T> on List<T> {
  List<T> unshift(T item, [ShiftType type = ShiftType.increment]) {
    final result = List<T>.from(this);
    if (type == ShiftType.increment) {
      return [item, ...result];
    } else {
      return result..remove(item);
    }
  }
}

extension UnshiftInt on int {
  int unshift([ShiftType type = ShiftType.increment]) {
    if (type == ShiftType.increment) {
      return this + 1;
    } else {
      return this - 1;
    }
  }
}
