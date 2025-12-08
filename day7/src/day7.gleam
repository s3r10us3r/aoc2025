import gleam/int
import gleam/set
import gleam/dict
import gleam/list
import gleam/string
import simplifile
import gleam/io

type Point {
  Point(x: Int, y: Int)  
}

fn read_data() {
  let assert Ok(content) = simplifile.read("data.txt")
  content 
    |> string.trim()
    |> string.to_graphemes()
    |> list.fold(#(Point(0, 0), dict.new(), Point(0,0)), fn (dt, ch) {
      let #(p, dct, s) = dt
      case ch {
      "\n" -> #(Point(0, p.y + 1), dct, s)
      "S" -> #(Point(p.x + 1, p.y), dict.insert(dct, p, "."), p)
      ch -> #(Point(p.x + 1, p.y), dict.insert(dct, p, ch), s)
    }
  })
}


fn solve1() {
  let #(_, map, s) = read_data()
  set.new() |> set.insert(s) |> solve1_rec(map)
}

fn solve1_rec(beams: set.Set(Point), map) {
  case set.size(beams) {
    0 -> 0
    _ -> {
      let #(new_beams, cnt) = set.fold(beams, #(set.new(), 0), fn(acc, beam) {
        let #(new_beams, cnt) = acc
        case dict.get(map, Point(beam.x, beam.y + 1)) {
          Ok("^") -> #(
            new_beams
            |> set.insert(Point(beam.x + 1, beam.y + 1))
            |> set.insert(Point(beam.x - 1, beam.y + 1)),
            cnt + 1
          )
          Ok(".") -> #(set.insert(new_beams, Point(beam.x, beam.y + 1)), cnt)
          _ -> acc
        }
      })
      cnt + solve1_rec(new_beams, map)
    }
  }
}


fn solve2() {
  let #(_, map, s) = read_data()
  let #(_, res) = solve2_rec(s, dict.new(), map)
  res
}

fn solve2_rec(beam: Point, visited: dict.Dict(Point, Int), map) {
  let next_pos = Point(beam.x, beam.y + 1)
  case dict.get(visited, next_pos) {
    Ok(val) -> #(visited, val)
    _ -> {
      let #(vis, score) = case dict.get(map, next_pos) {
        Ok("^") -> {
          let #(left_vis, left_val) = solve2_rec(Point(beam.x - 1, beam.y + 1), visited, map)
          let #(right_vis, right_val) = solve2_rec(Point(beam.x + 1, beam.y + 1), left_vis, map)
          #(right_vis, left_val + right_val)
        }
        Ok(".") -> solve2_rec(next_pos, visited, map)
        _ -> #(visited, 1)
      }
      let vis = dict.insert(vis, beam, score)
      #(vis, score)
    }
  }
}




pub fn main() -> Nil {
  solve1() |> int.to_string() |> io.println()
  solve2() |> int.to_string() |> io.println()
}
