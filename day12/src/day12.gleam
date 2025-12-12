import gleam/result
import gleam/set
import gleam/int
import gleam/dict
import gleam/list
import gleam/string
import simplifile
import gleam/io


fn solve1(shapes: dict.Dict(Int, Shape) , regions_parsed: List(Region)) {
  list.count(regions_parsed, fn(region) {
    let area = region.width * region.length
    let area_of_shapes = list.fold(dict.to_list(region.shapes), 0, fn(sum, dt) {
      let #(id, cnt) = dt
      let assert Ok(shape) = dict.get(shapes, id)
      let shape_area = list.length(shape.squares)
      shape_area * cnt + sum
    })
    area_of_shapes <= area
  })
}

fn solve1_helper(que: List(Int), grid: Grid, shapes_dict: dict.Dict(Int, Shape)) {
  let x_vals = list.range(0, grid.width - 1)
  let y_vals = list.range(0, grid.height - 1)
  case que {
    [] -> Error(True)
    [first, ..rest] -> {
      let assert Ok(shape) = dict.get(shapes_dict, first)
      let shapes = transform_shapes(shape)
      list.try_each(x_vals, fn(x) {
        list.try_each(y_vals, fn(y) {
          list.try_each(shapes, fn(shape) {
            case place(shape, grid, x, y) {
              Ok(new_grid) -> solve1_helper(rest, new_grid, shapes_dict)
              Error(_) -> Ok(Nil)
            }
          })
        })
      })
    }
  }
}

type Grid {
  Grid(width: Int, height: Int, taken: set.Set(#(Int, Int)))
}

fn place(shape: Shape, grid: Grid, t_x: Int, t_y: Int) -> Result(Grid, Nil) {
  list.try_fold(shape.squares, grid, fn(grid, sq) {
    let #(x, y) = sq
    case set.contains(grid.taken, #(x + t_x, y + t_y)) || grid.width <= x + t_x || grid.height <= y + t_y {
      True -> Error(Nil)
      False -> Ok(Grid(grid.width, grid.height, set.insert(grid.taken, #(x+t_x, y+t_y))))
    }
  })
}

type Shape {
  Shape(squares: List(#(Int, Int)))
}

fn transform_shapes(shape: Shape) -> List(Shape) {
  let r1 = rotate(shape)
  let r2 = rotate(r1)
  let r3 = rotate(r2)
  let m = mirror(shape)
  let mr1 = rotate(m)
  let mr2 = rotate(mr1)
  let mr3 = rotate(mr2)
  [shape, r1, r2, r3, m, mr1, mr2, mr3]
}

fn rotate(shape: Shape) {
  let new_shape = shape.squares
  |> list.map(fn(num) {
      let #(x,y) = num
      #(2 - y, x)
    })
  Shape(new_shape)
}

fn mirror(shape: Shape) {
  let new_shape = shape.squares
  |> list.map(fn(num) {
      let #(x, y) = num
      #(2 - x, y)
    })
  Shape(new_shape)
}

type Region {
  Region(width: Int, length: Int, shapes: dict.Dict(Int, Int))
}

fn read_data(path) {
  let assert Ok(content) = simplifile.read(path)
  let assert [regions, ..shape_list] = content
  |> string.trim()
  |> string.split("\n\n")
  |> list.reverse()

  let shapes = list.fold(shape_list, dict.new(), fn(shapes, shape) {
    let assert [ind_str, ..rows] = shape |> string.trim() |> string.split("\n")
    let assert Ok(ind_char) = string.to_graphemes(ind_str) |> list.first()
    let assert Ok(idx) = int.parse(ind_char)

    let #(_, shape_nested) = rows
    |> list.map_fold(0, fn(y, row) {
        let lst = []
        let row_idx = list.zip(string.to_graphemes(string.trim(row)), list.range(0,2))
        let row_lst = list.fold(row_idx, lst, fn(lst, ri) {
          let #(chr, i) = ri
          case chr {
            "#" -> [#(i, y), ..lst]
            _ -> lst
          }
        })
        #(y + 1, row_lst)
    })
    let shape_flat = list.flatten(shape_nested)
    let shp = Shape(shape_flat)
    dict.insert(shapes, idx, shp)
  })

  let regions_parsed = regions 
  |> string.trim()
  |> string.split("\n")
  |> list.map(fn(region_str) {
      let assert [size_str, sq_str] = region_str
      |> string.trim()
      |> string.split(": ")
      let assert [width, height] = size_str
      |> string.split("x")
      |> list.map(fn(n) {
        let assert Ok(num) = int.parse(n)
        num
      })
      let squares = sq_str
      |> string.trim()
      |> string.split(" ")
      |> list.map(fn (s) {
          let assert Ok(num) = int.parse(s)
          num
        })
      |> fn(l) {
          list.zip(list.range(0, list.length(l) - 1), l)
        }
      |> dict.from_list()
      Region(width, height, squares)
    })
  #(shapes, regions_parsed)
}

pub fn main() -> Nil {
  let #(shapes, regions) = read_data("data.txt")
  solve1(shapes, regions) |> int.to_string() |> io.println()
}
