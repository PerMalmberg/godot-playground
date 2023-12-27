extends GdUnitTestSuite

var scene: PackedScene = load("res://scene/fogofwar/FogOfWar.tscn")
var fog := scene.instantiate() as FogOfWar

func before() -> void:
    pass

func after() -> void:
    pass

func test_test() -> void:
    fog.add_revealer(null)
    assert_int(fog.get_revealers().size()).is_equal(1)