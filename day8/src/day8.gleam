import gleam/set
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import simplifile
import gleam/io

type Box {
  Box(x: Float, y: Float, z: Float)
} 

fn compute_box_dist(a: Box, b: Box) {
  let x = a.x -. b.x
  let y = a.y -. b.y
  let z = a.z -. b.z
  let assert Ok(res) = float.square_root({x *. x} +. {y *. y} +. {z *. z})
  res
}

fn read_data(path) {
  let assert Ok(content) = simplifile.read(path)
  let boxes = content 
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) {
    let splits = string.trim(line) |> string.split(",")
    case splits {
      [a, b, c] -> {
        let assert Ok(x) = float.parse(a <> ".0")
        let assert Ok(y) = float.parse(b <> ".0")
        let assert Ok(z) = float.parse(c <> ".0")
        Box(x, y, z)
      }
      _ -> panic as "invalid box"
    }
  })
  let indices = list.range(1, list.length(boxes))
  list.zip(indices, boxes)
}

fn solve1(boxes, cnt) {
  boxes
  |> list.combination_pairs()
  |> list.map(fn(dt) {
      let #(a, b) = dt
      let #(i_a, box_a) = a
      let #(i_b, box_b) = b
      let dist = compute_box_dist(box_a, box_b)
      #(i_a, i_b, dist)
    })
  |> list.sort(fn (a, b) {
      let #(_, _, d1) = a
      let #(_, _, d2) = b
      float.compare(d1, d2)
    })
  |> list.take(cnt)
  |> list.fold([], fn(cons, dt) {
      let #(i_a, i_b, _dist) = dt
      proccess_cons(i_a, i_b, cons)
    })
  |> fold_cons()
  |> list.map(set.size)
  |> list.sort(fn(i1, i2) {
      int.compare(i2, i1)
    })
  |> list.take(3)
  |> list.fold(1, int.multiply)
}

fn solve2(boxes, cnt) {
  let #(_, pair) = boxes
  |> list.combination_pairs()
  |> list.map(fn(dt) {
      let #(a, b) = dt
      let #(i_a, box_a) = a
      let #(i_b, box_b) = b
      let dist = compute_box_dist(box_a, box_b)
      #(i_a, i_b, dist)
    })
  |> list.sort(fn (a, b) {
      let #(_, _, d1) = a
      let #(_, _, d2) = b
      float.compare(d1, d2)
    })
  |> list.fold(#([], #(0, 0)), fn(acc, dt) {
      let #(i_a, i_b, _dist) = dt
      let #(cons, found) = acc
      let cons = [set.from_list([i_a, i_b]), ..cons]
      case found {
        #(0, 0) -> {
          let new_cons = fold_cons(cons)
          case new_cons {
            [s] -> {
              case set.size(s) == cnt {
                True -> #(new_cons, #(i_a, i_b))
                False -> #(new_cons, #(0,0))
              }
            }
          _ -> #(new_cons, #(0,0) )
          }
        }
        _ -> #(cons, found)
      }
    })
  let assert Ok(b1) = list.key_find(boxes, pair.0)
  let assert Ok(b2) = list.key_find(boxes, pair.1)
  b1.x *. b2.x
}


fn proccess_cons(i1, i2, cons) {
  case cons {
    [] -> [set.from_list([i1, i2])]
    [elem, ..rest] -> {
      case set.contains(elem, i1) || set.contains(elem, i2) {
        True -> [set.insert(elem, i1) |> set.insert(i2),..rest]
        False -> [elem, ..proccess_cons(i1, i2, rest)]
      }
    }
  }
}

fn fold_cons(cons) {
  case cons {
    [] -> []
    [con] -> [con]
    [con, ..rest] -> {
      let #(has_connected, new_cons) = list.map_fold(rest, False, fn(has_con, con2) {
        case set.is_disjoint(con, con2) {
          True -> #(has_con, con2)
          False -> #(True, set.union(con, con2))
        }
      })
      case has_connected {
        True -> fold_cons(new_cons)
        False -> [con, ..fold_cons(rest)]
      }
    }
  }
}

pub fn main() -> Nil {
  let boxes = read_data("data.txt")
  solve1(boxes, 1000) |> int.to_string() |> io.println()
  solve2(boxes, 1000) |> float.to_string() |> io.println()
}
