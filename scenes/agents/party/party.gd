class_name Party
extends Node3D
## Groups the party leader and its followers. Records the leader's path
## and tells each follower which point of that path to walk to.

## Leader controlled by the player.
@export var leader: PartyLeader
## Followers in order: the first one walks closest to the leader.
@export var followers: Array[PartyFollower] = []
## Distance along the path between consecutive party members, in meters.
@export var follow_spacing: float = 1.2
## Minimum distance between recorded path points, in meters.
@export var trail_point_spacing: float = 0.2
## Maximum number of recorded path points.
@export var trail_max_points: int = 64

var _trail: PositionTrail
var _following_enabled: bool = true


func _ready() -> void:
	assert(leader != null, "Party needs a leader")
	var trail_length := follow_spacing * followers.size()
	assert(trail_length / trail_point_spacing < trail_max_points, "trail_max_points too small for the party")
	_trail = PositionTrail.new(trail_point_spacing, trail_max_points)
	_trail.reset(leader.global_position, Vector3.BACK, trail_length)
	for i in followers.size():
		followers[i].global_position = _trail.sample_at_distance(_distance_for(i))


func _physics_process(_delta: float) -> void:
	if not _following_enabled:
		return
	_trail.record(leader.global_position)
	for i in followers.size():
		followers[i].set_follow_target(_trail.sample_at_distance(_distance_for(i)))


## Enables or disables exploration: player control of the leader and the
## followers walking behind it. Disabled, members stop moving on their own
## so other systems (like combat) can move them.
func set_exploration_enabled(enabled: bool) -> void:
	leader.set_controls_enabled(enabled)
	leader.set_physics_process(enabled)
	_following_enabled = enabled
	if enabled:
		_trail.reset(leader.global_position, Vector3.BACK, follow_spacing * followers.size())
	for follower in followers:
		follower.set_follow_target(follower.global_position)
		follower.set_physics_process(enabled)


## Returns the party members: the leader first, then the followers in order.
func get_members() -> Array[Node3D]:
	var members: Array[Node3D] = [leader]
	for follower in followers:
		members.append(follower)
	return members


## Returns the recruit of each member, in the same order as [method get_members].
func get_member_recruits() -> Array[RecruitData]:
	var recruits: Array[RecruitData] = [leader.recruit]
	for follower in followers:
		recruits.append(follower.recruit)
	return recruits


func _distance_for(index: int) -> float:
	return follow_spacing * (index + 1)
