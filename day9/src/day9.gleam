import gleam/result
import gleam/int
import gleam/list
import gleam/string
import gleam/io
import simplifile

type Point {
  Point(x: Int, y: Int)
}

type HorizontalLine {
  HorizontalLine(y: Int, s: Int, e: Int)
}

type VerticalLine {
  VerticalLine(x: Int, s: Int, e: Int)
}

fn read_data(path) {
  let assert Ok(content) = simplifile.read(path)
  content
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(line) {
    let splits = line |> string.trim() |> string.split(",")
    let assert Ok(f) = list.first(splits)
    let assert Ok(l) = list.last(splits)
    let assert Ok(x) = int.parse(f)
    let assert Ok(y) = int.parse(l)
    Point(x, y)
  })
}

fn solve1(data: List(Point)) {
  list.combination_pairs(data)
  |> list.map(fn(dt) {
    let #(a, b) = dt
    {int.absolute_value(a.x - b.x) + 1} * {int.absolute_value(a.y - b.y) + 1}
  })
  |> list.max(int.compare) |> result.unwrap(0)
}

fn solve2(data: List(Point)) {
  let assert [first, ..rest] = data
  let list_shifted = [first, ..list.reverse(rest)] |> list.reverse()
  let #(h_lines, v_lines) = data
  |> list.zip(list_shifted)
  |> get_lines([], [])
  list.combination_pairs(data)
  |> list.map(fn(dt) {
    let #(a,b) = dt
    let sx = int.min(a.x, b.x)
    let ex = int.max(a.x, b.x)
    let sy = int.min(a.y, b.y)
    let ey = int.max(a.y, b.y)
    case list.all(h_lines, fn(l) {does_horizontal_not_cross(l, sx, ex, sy, ey)}) && list.all(v_lines, fn(l) {does_vertical_not_cross(l, sx, ex, sy, ey)}) {
      True -> {int.absolute_value(a.x - b.x) + 1} * {int.absolute_value(a.y - b.y) + 1}
      False -> 0
    }
  })
  |> list.max(int.compare) |> result.unwrap(0)
}

fn get_lines(data: List(#(Point, Point)), horizontal_lines: List(HorizontalLine), vertical_lines: List(VerticalLine)) {
  case data {
    [] -> #(horizontal_lines, vertical_lines)
    [first, ..rest] -> {
      let #(p1, p2) = first
      case p1.x == p2.x {
        True -> get_lines(rest, horizontal_lines, [VerticalLine(p1.x, int.min(p1.y, p2.y), int.max(p1.y, p2.y)), ..vertical_lines])
        False -> get_lines(rest, [HorizontalLine(p1.y, int.min(p1.x, p2.x), int.max(p1.x, p2.x)), ..horizontal_lines], vertical_lines)
      }
    }
  }
}

fn does_horizontal_not_cross(line: HorizontalLine, sx, ex, sy, ey) {
  case line.y > sy && line.y < ey {
    False -> True
    True -> {
      let is_inside = line.e <= ex && line.s >= sx
      let is_outside = line.s <= sx && line.e >= ex
      let cross_left = line.s > sx && line.s < ex
      let cross_right = line.e > sx && line.e < ex
      !{is_inside || is_outside || cross_left || cross_right}
    }
  }
}

fn does_vertical_not_cross(line: VerticalLine, sx, ex, sy, ey) {
  case line.x > sx && line.x < ex {
    False -> True
    True -> {
      let is_inside = line.e <= ey && line.s >= sy
      let is_outside = line.s <= sy && line.e >= ey
      let cross_left = line.s > sy && line.s < ey
      let cross_right = line.e > sy && line.e < ey
      !{is_inside || is_outside || cross_left || cross_right}
    }
  }
}

pub fn main() -> Nil {
  let data = read_data("data.txt")
  solve1(data) |> int.to_string() |> io.println()
  solve2(data) |> int.to_string() |> io.println()
}
