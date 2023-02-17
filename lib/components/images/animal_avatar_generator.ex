defmodule AnimalAvatarGenerator do
  @moduledoc """
  Generate SVG avatars from a string seed. It should always return the same avatar for the corresponding seed.

  Based on https://www.npmjs.com/package/animal-avatar-generator (translated to Elixir, mostly by ChatGPT)
  """

  # TODO: optimise and extract into library

  @background_colors [
    "#fcf7d1",
    "#ece2e1",
    "#e4e3cd",
    "#c4ddd6",
    "#b5f4bc"
  ]

  @avatar_colors [
    "#d7b89c",
    "#b18272",
    "#ec8a90",
    "#a1Ac88",
    "#99c9bd",
    "#50c8c6"
  ]

  def avatar(
        seed,
        opts \\ []
      ) do
    seed_randomiser(seed)

    opts =
      [
        size: 150,
        # Palette for avatar colors
        avatar_colors: @avatar_colors,
        # Palette for background colors
        background_colors: @background_colors,
        # Blackout the right side of avatar
        blackout: true,
        # Use round or rectangle background
        round: true,
        skip_randomizer: true
      ]
      |> Keyword.merge(opts)

    background_color = Enum.random(opts[:background_colors])

    create_svg(opts[:size], [
      create_background(opts[:round], background_color, opts[:background_class]),
      avatar_face(
        seed,
        opts
      ),
      if(opts[:blackout], do: create_blackout(opts[:round]), else: "")
    ])
  end

  def avatar_face(
        seed,
        opts \\ []
      ) do
    opts[:skip_randomizer] || seed_randomiser(seed)

    avatar_color = Enum.random(opts[:avatar_colors])

    shapes = [
      faces(),
      optional(patterns()),
      ears(),
      optional(hairs()),
      muzzles(),
      eyes(),
      brows()
    ]

    Enum.map(shapes, &Enum.random(&1))
    |> List.flatten()
    |> Enum.map(& &1.(avatar_color))
    |> Enum.join("")
  end

  def empty_shape do
    [
      fn _color -> "" end
    ]
  end

  def brows do
    [
      fn _color ->
        """
        <ellipse fill="#15212a" cx="348" cy="190.6" rx="8.3" ry="19.4" transform="rotate(-57.5 348 190.6)"/>
        <ellipse fill="#15212a" cx="152" cy="205.1" rx="19.4" ry="8.3" transform="rotate(-32.5 152 205)"/>
        """
      end,
      fn _color ->
        """
        <path fill="#15212a" d="M333 196.7h-.4l-27.6-2.1a5 5 0 01.8-10l27.5 2a5 5 0 01-.3 10zM166.6 196.7h.4l27.5-2.1a5 5 0 00-.7-10l-27.6 2a5 5 0 00.4 10z"/>
        """
      end,
      fn _color ->
        """
        <path fill="#15212a" d="M139.8 203c-1 0-2-.3-2.8-.9a5 5 0 01-1.3-7c10.5-15.5 25.8-20.4 45.7-14.5a5 5 0 11-2.9 9.6c-15.6-4.7-26.6-1.3-34.5 10.6a5 5 0 01-4.2 2.2zM361.4 203a5 5 0 01-4.2-2.2c-8-12-19-15.3-34.5-10.6a5 5 0 11-2.9-9.6c19.9-6 35.2-1 45.7 14.6a5 5 0 01-4.1 7.8z"/>
        """
      end
    ]
  end

  def ears do
    [
      fn color ->
        """
          <path fill="#{color}" d="M169 122.4a184.8 184.8 0 00-79.3 63.4c-6.5 9-12 18.8-16.5 29C64.7 177.9 46.6 85.4 78.9 84c27-1.1 66.6 22.4 90.1 38.3zM426.7 214.5c-3.9-8.7-8.5-17-13.7-24.9a184.5 184.5 0 00-82.1-67.3c23.5-15.8 63.1-39.4 90-38.2 32.3 1.3 14.3 93.3 5.8 130.4z"/>
          <path fill="#fec3aa" d="M149.2 132.2c-23.9 13.6-44.3 32-59.5 53.6-5.7-27-13.2-74.9 5.5-75.7 15.9-.6 38.7 12.1 54 22zM413 189.6a184.5 184.5 0 00-65.4-59.1c16.7-11 42-25.3 59.6-24.6 20.6 1 12 54.6 5.8 83.7z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{darken(color, 30)}" d="M71.4 144.8c-7.5-15.8 70.4-53.2 78-37.5 8.7 23 7.8 43-1.6 60.6a32 32 0 01-33.8 16.5c-21.4-3.7-35.8-16.6-42.6-39.6zM423.4 144.8c7.6-15.8-70.3-53.2-78-37.5-8.7 23-7.7 43 1.7 60.6a32 32 0 0033.8 16.5c21.4-3.7 35.8-16.6 42.5-39.6z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{darken(color, 30)}" d="M169 122.4C124 57.5 37.6 128 57 176.8c22.1 31.3 49.5 25.6 82.5-20.4a36 36 0 006.7-22.5c7.6-4.4 15.1-8.3 22.8-11.5zM331 122.4c44.9-64.9 131.4 5.7 112 54.4-22.1 31.3-49.5 25.6-82.5-20.4a36 36 0 01-6.7-22.5c-7.6-4.4-15.1-8.3-22.8-11.5z"/>
          <path fill="#15212a" d="M146.2 134c-.8-14-5-23.9-13.5-28 11.2-1 21.6 4.6 30.8 18.8l-17.3 9.1zM353.8 134c.8-14 5-23.9 13.5-28-11.2-1-21.6 4.6-30.8 18.8l17.3 9.1z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{color}" d="M169 122.4a194.5 194.5 0 00-56.5 37c-29.4-10.7-40.3-32.4-41-60.1 37-5.4 76.7-3 97.4 23.1zM331 122.4a194.5 194.5 0 0156.4 37c29.5-10.7 40.4-32.4 41.1-60.1-37-5.4-76.7-3-97.5 23.1z"/>
          <path fill="#fec3aa" d="M148.6 132.6c-12.3 7-23.7 15.4-33.9 24.7-20.7-8.3-28.4-24.3-29-44.6 27.2-4 49.4.6 62.9 19.9zM351.4 132.6c12.3 7 23.6 15.4 33.8 24.7 20.8-8.3 28.5-24.3 29-44.6-27.1-4-49.3.6-62.8 19.9z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{darken(color, 60)}" d="M107.1 128.2c-47.4 23-20.8 59 31.7 51.7 7.2-1 13.2-6.2 15.3-13.2 15.1-50.7-17-82-47-38.5zM392.2 128.2c47.4 23 20.8 59-31.8 51.7-7.2-1-13.1-6.2-15.2-13.2-15.1-50.7 17-82 47-38.5z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{color}" d="M169 122.4a192.3 192.3 0 00-68 49C76.4 142 81.3 125 110 88c31.7 0 58.3 4.1 59 34.5zM331 122.4a192.3 192.3 0 0168 49c24.6-29.4 19.6-46.4-9-83.5-31.7 0-58.3 4.1-59 34.5z"/>
          <path fill="#fec3aa" d="M155.6 128.7c-20 10.5-37.8 24.1-52.4 40.2-16.6-20.5-20.3-33.3.4-60 21.5 0 47 2.5 52 19.8zM344.4 128.7c20 10.5 37.8 24.1 52.4 40.2 16.6-20.5 20.3-33.3-.4-60-21.5 0-47 2.5-52 19.8z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{color}" d="M104.3 167.8a176.9 176.9 0 00-21.6 28.8 67.7 67.7 0 01-24.4-12.8 38.1 38.1 0 01-14.1-29.4c-.4-7 .7-13.8 1.8-19.5 2.6-13.3 52.2 27.8 58.3 32.9zM395.8 167.8a176.9 176.9 0 0121.6 28.8 67.7 67.7 0 0024.4-12.8 38.1 38.1 0 0014.1-29.4c.3-7-.7-13.8-1.9-19.5-2.6-13.3-52.2 27.8-58.2 32.9z"/>
          <path fill="#fec3aa" d="M91.3 183.6c-3.1 4.2-6 8.5-8.6 13a67.7 67.7 0 01-24.4-12.8 38.1 38.1 0 01-14.1-29.4c6.6.3 22 2 30.3 11 5.4 5.7 11.8 12.7 16.8 18.2zM408.8 183.6c3 4.2 6 8.5 8.6 13a67.7 67.7 0 0024.4-12.8 38.1 38.1 0 0014.1-29.4c-6.7.3-22 2-30.3 11-5.5 5.7-11.8 12.7-16.8 18.2z"/>
          <path fill="#937155" d="M114 61.8s6.7-1 9.5 6.8 1 20.3 8.3 24.1c7.4 3.8 17.2 1.2 16.8-9.8-.4-11 3.2-19.3 10.7-15 7.6 4.5 10.6 13.6 9.4 30.2s-1 36.3-5.2 41.7c-4.2 5.3-20.1 5.3-25.5-2.2-5.4-7.6-8-11-16.3-16a61.2 61.2 0 01-24.1-29.3c-3.4-11.5-1.3-32.7 16.5-30.5zM385.8 61.8s-6.6-1-9.4 6.8-1 20.3-8.3 24.1c-7.4 3.8-17.2 1.2-16.8-9.8.4-11-3.2-19.3-10.8-15-7.5 4.5-10.5 13.6-9.3 30.2s1 36.3 5.2 41.7c4.2 5.3 20 5.3 25.5-2.2 5.4-7.6 8-11 16.3-16 8.4-5 20.7-17.7 24.1-29.3 3.4-11.5 1.2-32.7-16.5-30.5z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{darken(color, 60)}" d="M46.1 205.5c2-34.2 73.5-80.3 97.5-80.3S119 235.2 107 243.5s-62.8-3.7-61-38zM454 205.5c-2-34.2-73.5-80.3-97.5-80.3s24.6 110 36.4 118.3 62.9-3.7 61-38z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{color}" d="M132.3 143a185.8 185.8 0 00-42.6 42.7c-28.4-20.8-36.5-43-31.4-66.4a86.2 86.2 0 018.4-22.1c33.5 4 56.8 18 65.6 45.9zM409.9 185.1a176.3 176.3 0 00-43.1-42.7c9-27.4 32.1-41.2 65.4-45.2 4 7.5 6.8 14.8 8.3 22.1 5.1 23.1-2.8 45.2-30.6 65.8z"/>
          <path fill="#fec3aa" d="M103.9 168.2c-5.1 5.5-9.9 11.4-14.2 17.5-28.4-20.8-36.5-43-31.4-66.4 6.8 2.4 16.2 6.7 27 14.4a48.3 48.3 0 0118.6 34.5zM409.9 185.1c-4.5-6.3-9.4-12.3-14.7-18a47.9 47.9 0 0118.4-33.4c10.8-7.7 20.1-12 27-14.4 5 23.1-3 45.2-30.7 65.8z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{color}" d="M396.4 168.5l-4-4.2a190.3 190.3 0 00-74.2-47c9.7-15.7 38.6-48.2 59.6-54.2 4.6-1.4 9.6.7 12 4.8 22.4 38.8 11.6 84.5 6.6 100.6zM103.6 168.5l4-4.2a190.3 190.3 0 0174.2-47c-9.7-15.7-38.6-48.2-59.6-54.2-4.6-1.4-9.6.7-12 4.8-22.4 38.8-11.6 84.5-6.6 100.6z"/>
          <path fill="#fec3aa" d="M392.4 164.3a190.3 190.3 0 00-57.6-40.2c8.4-12.5 28.6-34.4 43.4-38.7a8 8 0 019 3.6c16.8 28.9 9 62.8 5.2 75.3zM107.6 164.3a190.3 190.3 0 0157.6-40.2c-8.4-12.5-28.6-34.4-43.4-38.7a8 8 0 00-9 3.6c-16.8 28.9-9 62.8-5.2 75.3z"/>
        """
      end,
      fn color ->
        """
          <path fill="#813d14" d="M399.9 72.3c-2.1 5.7-4.5 11.3-7.8 16.8l-.6 1-.6 1-1.4 2.1-1.5 2-1.6 2-1.8 1.8c-.6.6-1.1 1.2-1.8 1.7l-2 1.7-1 .8-1 .7c-5.7 4-12.1 6.5-18.4 8-5 1.3-10 2-15 2.6-1 4.3-2.4 8.5-4.1 12.6-5-2.4-10-4.7-15.1-6.7 2-3.8 3.6-7.9 4.8-12a86.7 86.7 0 003-20.4c.2-7-.2-14-1.1-21.2-1-7.1-2.3-14.2-4-21.3v-.1a5 5 0 019.7-2.6c2.3 7.2 4.3 14.5 5.9 22a147.8 147.8 0 013 33.3c3.4-.1 6.7-.4 10-.8 5.1-.8 9.9-2.2 14-4.5l.8-.5.8-.5 1.5-1 1.4-1.1 1.4-1.2 1.3-1.4 1.3-1.3 1.2-1.5.6-.8.6-.8c3.1-4.2 5.8-9.2 8.3-14.3a5 5 0 019.2 4zM100.3 72.3c2 5.7 4.4 11.3 7.7 16.8l.6 1 .7 1 1.4 2.1 1.5 2 1.5 2 1.8 1.8 1.8 1.7 2 1.7 1 .8 1 .7c5.7 4 12.2 6.5 18.4 8 5 1.3 10.1 2 15 2.6 1 4.3 2.4 8.5 4.2 12.6 4.9-2.4 10-4.7 15-6.7-2-3.8-3.5-7.9-4.7-12a86.7 86.7 0 01-3-20.4c-.2-7 .2-14 1-21.2 1-7.1 2.4-14.2 4-21.3v-.1a5 5 0 00-9.6-2.6c-2.3 7.2-4.4 14.5-6 22a147.8 147.8 0 00-3 33.3c-3.4-.1-6.7-.4-9.9-.8-5.2-.8-10-2.2-14.1-4.5l-.8-.5-.7-.5-1.5-1-1.4-1.1-1.4-1.2-1.3-1.4c-.5-.4-1-.8-1.3-1.3l-1.3-1.5-.6-.8-.6-.8a93.6 93.6 0 01-8.2-14.3 5 5 0 00-9.3 4z"/>
          <path fill="#{color}" d="M408 148.5c-5.9 3.7-13.4 6.7-22.6 9-10.8-10-23-18.8-36.1-26.1a57 57 0 0138.7-18.1c10.8-.9 22.6.5 35.4 3.9 1.6 13.5-3.6 23.8-15.4 31.3zM92 148.5c6 3.7 13.5 6.7 22.6 9 10.8-10 23-18.8 36.2-26.1a57 57 0 00-38.8-18.1c-10.8-.9-22.6.5-35.4 3.9C75 130.7 80.3 141 92 148.5z"/>
          <path fill="#15212a" d="M408 148.5c19.7-24.5 3.3-31.5-20-35.2 10.8-.9 22.6.5 35.4 3.9 1.6 13.5-3.6 23.8-15.4 31.3zM92 148.5c-19.7-24.5-3.2-31.5 20-35.2-10.8-.9-22.6.5-35.4 3.9C75 130.7 80.3 141 92 148.5z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{color}" d="M401.5 174.3l-5.9-6.7a185.5 185.5 0 00-39.2-32c24.6-43.7 98-5.4 45 38.7zM98.5 174.3l6-6.7a185.5 185.5 0 0139.1-32c-24.5-43.7-98-5.4-45 38.7z"/>
          <path fill="#fec3aa" d="M395.6 167.6c-8.7-9.4-18.6-18-29.3-25.5 16.3-26.9 62.3-2.6 29.3 25.5zM104.4 167.6c8.8-9.4 18.6-18 29.3-25.5-16.3-26.9-62.3-2.6-29.3 25.5zM360 71.1l-1 14.7-1.7 27.9-.3 6.3-1 15.3a201 201 0 00-72-26.6l18.7-28.8 10.9-17 4.3-6.6c2.3-3.7 6.9-5.2 11-3.7l25 9.3a9.3 9.3 0 016 9.2zM216.1 108.7a201 201 0 00-71.9 26.6l-1-15.3-.3-6.3-1.7-27.9-.9-14.7c-.2-4 2.2-7.8 6-9.2l25-9.3c4.1-1.5 8.7 0 11 3.7l4.3 6.6 10.3 16 .7 1 10.2 15.8 8.3 13z"/>
          <path fill="#{color}" d="M337.5 72c0 5-10.5 9-23.5 9-4.1 0-8-.4-11.4-1.1l11-17h.4c13 0 23.5 4 23.5 9zM359 85.8l-1.7 27.9c-11.9-1.3-20.8-7-20.8-13.9 0-7.2 9.8-13.1 22.5-14zM207.8 95.7a73 73 0 01-13 3.8c-15.6 3.1-29 1.2-30-4.3-1.1-5.4 10.6-12.3 26-15.4l6.1-1 .7 1 10.2 16z"/>
        """
      end,
      fn color ->
        """
          <path fill="#b4a5a5" d="M141.3 140c2.3 7.6 28.7-1.3 26-13.2 0-64.8-28.5-105.3-67-50.6 25.7-13 39.8 7 41 63.8zM358.7 140c-2.3 7.6-28.7-1.3-26.1-13.2 0-64.8 28.6-105.3 67.1-50.6-25.8-13-39.8 7-41 63.8z"/>
          <path fill="#{color}" d="M135.9 140.5a177 177 0 00-55.7 60.3c-107.4-4-38.6-64.3 55.7-60.3zM364.1 140.5a177 177 0 0155.7 60.3c107.3-4 38.6-64.3-55.7-60.3z"/>
          <path fill="#fff" d="M388.7 160.6a177 177 0 0128 34.9c68.8-1 72.8-34.4-28-35zM111.3 160.6a177 177 0 00-28 34.9c-68.8-1-72.8-34.4 28-35z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{color}"  d="M156.6 128.2c-21.3 11-40 25.5-55.1 42.6v.1l-.2.2-.2.1-1.6-88.7s1.8 0 5 1.2h.1c5 2 13.2 7.2 23.1 20.7a76.1 76.1 0 0028.9 23.8zM343.4 128.2c21.2 11 40 25.5 55.1 42.6v.1l.2.2.2.1 1.6-88.7s-1.8 0-5 1.2h-.1c-5 2-13.2 7.2-23.1 20.7a76.1 76.1 0 01-28.9 23.8z"/>
          <path fill="#fec3aa" d="M109.3 160.3c-2.9 3.4-5.4 6.9-7.8 10.5v.1l-.2.2-.2.1c-1 0-6.3-1-23.7-16a46.1 46.1 0 01-13-56.8c5.9-11.9 24-22 40.2-14.7a36.2 36.2 0 0115.8 14.9c12.2 20-1.5 47-11.2 61.7zM390.7 160.3c2.9 3.4 5.4 6.9 7.8 10.5v.1l.2.2.1.1c1.1 0 6.4-1 23.7-16a46.1 46.1 0 0013.1-56.8c-5.9-11.9-24-22-40.2-14.7a36.2 36.2 0 00-15.8 14.9c-12.2 20 1.5 47 11.1 61.7z"/>
        """
      end
    ]
  end

  def eyes do
    [
      fn _color ->
        """
          <circle cx="169" cy="250" r="20.4" fill="#15212a"/>
          <circle cx="175.4" cy="255.8" r="9.6" fill="#fff"/>
          <circle cx="159.4" cy="241" r="4.2" fill="#fff"/>
          <circle cx="331" cy="250" r="20.4" fill="#15212a"/>
          <circle cx="324.6" cy="255.8" r="9.6" fill="#fff"/>
          <circle cx="340.6" cy="241" r="4.2" fill="#fff"/>
        """
      end,
      fn _color ->
        """
          <circle cx="169" cy="254.2" r="18.9" fill="#15212a"/>
          <circle cx="175.9" cy="258.3" r="6.3" fill="#fff"/>
          <circle cx="331" cy="254.2" r="18.9" fill="#15212a"/>
          <circle cx="324.1" cy="258.3" r="6.3" fill="#fff"/>
        """
      end,
      fn _color ->
        """
          <circle cx="169" cy="254.5" r="17.2" fill="#15212a"/>
          <circle cx="175.3" cy="247.8" r="5.9" fill="#fff"/>
          <circle cx="331" cy="254.5" r="17.2" fill="#15212a"/>
          <circle cx="324.7" cy="247.8" r="5.9" fill="#fff"/>
        """
      end,
      fn _color ->
        """
          <circle fill="#15212a" cx="331.04" cy="253.21" r="22.21"/>
          <circle fill="#fff" cx="338.81" cy="246.07" r="8.97"/>
          <circle fill="#fff" cx="322.5" cy="263.97" r="5.01"/>
          <circle fill="#15212a" cx="168.96" cy="253.21" r="22.21"/>
          <circle fill="#fff" cx="161.19" cy="246.07" r="8.97"/>
          <circle fill="#fff" cx="177.5" cy="263.97" r="5.01"/>
        """
      end,
      fn _color ->
        """
          <circle fill="#15212a" cx="168.62" cy="248.28" r="15.49"/>
          <circle fill="#fff" cx="163.62" cy="242.97" r="4.95"/>
          <circle fill="#15212a" cx="331.04" cy="248.28" r="15.49"/>
          <circle fill="#fff" cx="336.04" cy="242.97" r="4.95"/>
        """
      end,
      fn _color ->
        """
          <path fill="#15212a" d="M339.3 256.8c0 15.3-8 15.1-17.9 15.1-9.8 0-17.8.2-17.8-15 0-15.4 8-27.8 17.8-27.8 9.9 0 17.9 12.4 17.9 27.7z"/>
          <ellipse cx="329.2" cy="241.9" fill="#fff" rx="5.1" ry="7.5" transform="rotate(-22 329.2 242)"/>
          <path fill="#15212a" d="M196.5 256.8c0 15.3-8 15.1-18 15.1s-17.8.2-17.8-15c0-15.4 8-27.8 17.9-27.8s17.9 12.4 17.9 27.7z"/>
          <ellipse cx="186.4" cy="241.9" fill="#fff" rx="5.1" ry="7.5" transform="rotate(-22 186.4 242)"/>
        """
      end,
      fn _color ->
        """
          <circle fill="#15212a" cx="180.11" cy="258.32" r="17.11"/>
          <circle fill="#fff" cx="174.66" cy="252.88" r="5.44"/>
          <circle fill="#15212a" cx="320.02" cy="258.32" r="17.11"/>
          <circle fill="#fff" cx="314.58" cy="252.88" r="5.44"/>
        """
      end,
      fn _color ->
        """
          <circle fill="#15212a" cx="168.96" cy="262.77" r="18.38"/>
          <circle fill="#fff" cx="163.12" cy="256.93" r="5.84"/>
          <circle fill="#15212a" cx="331.04" cy="262.77" r="18.38"/>
          <circle fill="#fff" cx="325.2" cy="256.93" r="5.84"/>
        """
      end
    ]
  end

  def faces do
    [
      fn color ->
        """
          <path fill="#{color}" d="M440.7 280.2c0 6.7-.4 13.1-1.2 19.2-1.1 7.9-2.9 15.2-5.3 21.9a86.3 86.3 0 01-20.7 32.6C393 374.3 362 385.2 325 390.6c-23 3.3-48.3 4.5-74.9 4.5a529 529 0 01-75-4.6c-68-9.8-115.7-38.4-115.7-110.3 0-96.3 85.4-174.3 190.7-174.3 95.7 0 175 64.4 188.6 148.3a161 161 0 012.1 26z"/>
        """
      end
    ]
  end

  def hairs do
    [
      fn _color ->
        """
          <path fill="#fef6f4" d="M332 100.7c-10.2-27.5-29.9-29.9-53.6-21.5C273.2 72.5 266 67 250 66.3c-15.9.6-23.2 6.2-28.4 13-23.8-8.5-43.4-6.1-53.5 21.4-39 19.8-5.9 84.7 33 64.8 10.9 12 24.4 19.1 48.9 5.7 24.5 13.4 38 6.3 48.9-5.7 38.9 19.9 72-45 33-64.8z"/>
        """
      end,
      fn _color ->
        """
          <path fill="#eabf9f" d="M202.2 99.6c34-8 67.5-7.6 100.4.9 9.3 2.3 14.9 8 13.7 14-7.5 39.7-60.1 79.2-70 71.6-10.8-8.2 2.3-31.4-9.5-33.1-10.4-1.5-25.9 15.9-37.8 11.8-2.7-.9-4.3-2.7-4.2-4.6a161 161 0 00-5.6-46.6c-1.8-6 3.6-11.8 13-14z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{darken(color, 30)}" d="M297.8 78.3a4.8 4.8 0 01-4.2 5.2c-4.2.4-8.3 1-12.2 2-3.9 1-7.6 2.6-11 4.6a37.6 37.6 0 00-12.9 12.3l-1.5 2.7-.5.9a165.9 165.9 0 00-8.8 0l-1.5-3c-.9-.6-1.8-1.3-2.8-1.8-3-1.6-6.3-2.5-9.6-2.8-6.8-.6-13.7.6-20.5 2.4a3.8 3.8 0 11-1.5-7.5c3.7-.5 7.5-.9 11.3-1 3.8 0 7.7.3 11.5 1.1 2.2.5 4.4 1.2 6.5 2.2-2-2.4-4.3-4.6-6.9-6.5-6.9-5-15.4-7.3-24.1-7.6a5.7 5.7 0 11.4-11.5h.6c5.1.7 10.3 2 15.2 4a47.7 47.7 0 0123 20 65.6 65.6 0 00-11.5-38.4 6.7 6.7 0 1111.7-6.7v.1a76.7 76.7 0 017 44 42 42 0 0110.3-10c4-2.8 8.5-4.9 13-6.3 4.6-1.4 9.2-2.4 13.9-2.8 2.6-.2 5 1.8 5.1 4.4z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{color}" d="M309.5 114.6c-18.7-5.6-38.7-8.6-59.4-8.6 -10.6 0-21 0.8-31.1 2.3 -8.1-10.8-13-23.6-14-37 0-0.4-0.1-0.8-0.1-1.2 -0.6-11.3 5.6-23.1 5.6-23.1s1.8 10.8 8.9 24.3c7 13.2 19.6 18.4 20 18.6 -0.1-0.2-3.4-4.4-1.2-21.4 2.6-19.5 18.6-28.4 18.6-28.4s-4 11.7-2 25c2.5 16.2 15.9 27.3 15.9 27.3s0.3-8.3 5.2-21.5c4.9-13.2 15.7-20.7 15.7-20.7s-2.4 9.8-2.4 27.9C289 93.1 304.5 109.6 309.5 114.6z"/>
        """
      end
    ]
  end

  def muzzles do
    [
      fn _color ->
        """
          <path fill="#fff" d="M299.9 307.2c0 35-22.3 63.3-49.9 63.3s-49.9-28.3-49.9-63.3 22.4-46.7 49.9-46.7 49.9 11.8 49.9 46.7z"/>
          <path fill="#f3252f" d="M250 315l12.3 7.8c0 23-24.2 23.2-24.4.4v-.4l12.1-7.7z"/>
          <path fill="#15212a" d="M285.2 316c-.8-.3-1.6.2-1.8 1-.9 2.9-3.1 4.8-6.7 5.7A26.5 26.5 0 01254 316c-.5-.5-1-1-1.3-1.6v-7.2c15-1 26.7-11 26.7-22.9 0-12.7-13.2-11.2-29.4-11.2s-29.4-1.5-29.4 11.2c0 12 11.8 21.9 26.8 22.9v7c-.4.7-.9 1.3-1.4 1.8a26.6 26.6 0 01-22.7 6.6c-3.6-1-5.9-2.8-6.7-5.7-.2-.8-1-1.3-1.8-1-.8.2-1.3 1-1 1.8 1 4 4.1 6.6 8.7 7.8a29.9 29.9 0 0025.6-7.3c.8-.8 1.4-1.6 1.9-2.4.5.8 1.1 1.6 1.9 2.3a29.9 29.9 0 0025.6 7.4c4.6-1.2 7.6-3.9 8.8-7.8.2-.8-.3-1.6-1-1.9z"/>
        """
      end,
      fn _color ->
        """
          <path fill="#fff" d="M324.7 343.4c0 34.5-33.4 29.8-74.7 29.8s-74.7 4.7-74.7-29.8 33.4-62.2 74.7-62.2 74.7 27.8 74.7 62.3z"/>
          <path fill="#15212a" d="M274.4 312.3c-.9 0-1.5.7-1.5 1.5 0 6-5.6 8.7-10.7 8.7-4.9 0-10.1-2.5-10.6-7.8v-14.3c13-.1 23.3-1.5 23.3-10.1 0-9-11.2-16.2-24.9-16.2s-24.9 7.2-24.9 16.2c0 8.6 10.3 10 23.3 10v14.5c-.5 5.3-5.7 7.7-10.6 7.7-5.1 0-10.6-2.7-10.6-8.7a1.5 1.5 0 10-3 0c0 3.6 1.5 6.7 4.4 8.8 2.4 1.9 5.7 2.9 9.2 2.9 4.9 0 9.8-2.1 12.2-6.1.7 1.2 1.7 2.3 3 3.2 2.4 1.8 5.7 2.8 9.2 2.8 6.8 0 13.7-4 13.7-11.6 0-.8-.7-1.5-1.5-1.5z"/>
        """
      end,
      fn color ->
        """
          <ellipse cx="250" cy="299.3" fill="#{darken(color, 30)}" rx="39.7" ry="27.6"/>
          <path fill="#{darken(color, 60)}" d="M229.1 315.4c-1.2 1.4-3.3 1.6-5.4.9a8.2 8.2 0 01-4.7-4.3c-1-2-.9-4 .3-5.3 1.4-1.5 3.7-1.8 5.9-.8a8.3 8.3 0 014.1 3.7c1.1 2 1.1 4.3-.2 5.8zM281 312a8.5 8.5 0 01-4.7 4.3c-2 .7-4.1.4-5.4-1-1.2-1.4-1.2-3.6-.2-5.6a8.5 8.5 0 014.2-3.8c2.2-1 4.5-.7 5.8.8 1.2 1.3 1.3 3.4.4 5.4z"/>
          <path fill="#15212a" d="M281 312a26.6 26.6 0 00-6.1-6.1c-.8.3-1.6.8-2.3 1.4-.8.7-1.4 1.5-1.9 2.4a3 3 0 001 1.5 19 19 0 014.6 5c1.3 2.2 2 4.5 2 7 0 10.2-12.7 18.6-28.3 18.6s-28.3-8.4-28.3-18.7c0-2.4.7-4.7 2-6.8a19 19 0 014.5-5.1c.6-.4 1-1 1-1.6a8.3 8.3 0 00-4-3.7c-.3 0-.6.2-.9.4-2 1.7-3.9 3.6-5.3 5.7a19.5 19.5 0 00-3.6 11.1c0 13.8 15.5 25 34.6 25s34.6-11.2 34.6-25c0-4-1.3-7.7-3.5-11z"/>
        """
      end,
      fn _color ->
        """
          <ellipse cx="250" cy="315" fill="#fff" rx="73.7" ry="48.3"/>
          <path fill="#15212a" d="M270 272a20 20 0 01-40.1 0c0-11.1 9-13.7 20-13.7 11.2 0 20.2 2.6 20.2 13.7z"/>
          <path fill="#f3252f" d="M240.2 306c0 21.3 19.6 21.3 19.6 0l-7.3-3.6-3.4-3.5-3.3 6-5.6 1.1z"/>
          <path fill="#15212a" d="M270.2 292c-.8-.1-1.5.5-1.6 1.3-.3 5-2.4 8.7-5.6 10.2a7.3 7.3 0 01-7.3-.5c-2.6-1.7-4-4.8-4.2-8.7v-1-1.1c0-.8-.6-1.6-1.4-1.6h-.1-.1c-.9 0-1.5.8-1.4 1.6v2.1c-.2 3.9-1.7 7-4.2 8.7a7.3 7.3 0 01-7.4.5c-3.2-1.5-5.2-5.3-5.5-10.2-.1-.8-.8-1.4-1.6-1.4-.9 0-1.5.8-1.4 1.6.4 6 3 10.7 7.2 12.7a10.4 10.4 0 0010.3-.7c1.8-1.1 3.1-2.8 4-4.8 1 2 2.3 3.7 4 4.8a10.3 10.3 0 0010.4.7c4.2-2 6.9-6.7 7.3-12.7 0-.8-.6-1.5-1.4-1.6z"/>
        """
      end,
      fn _color ->
        """
          <path fill="#15212a" d="M278.3 286.2a2 2 0 00-2 2c0 9.5-12.2 14.6-24.6 15V290h-3.4v13.2c-12.5-.4-24.6-5.5-24.6-15 0-1-.8-2-2-2s-2 1-2 2c0 6 3.5 11.1 10 14.6a44 44 0 0020.3 4.5c14.6 0 30.3-6 30.3-19 0-1.2-1-2-2-2z"/>
          <path fill="#15212a" d="M272.4 275c0-6.4-10.1-11.6-22.5-11.6s-22.5 5.2-22.5 11.5c0 2 1.1 4 3 5.7 1 .8 2 1.7 3.2 2.4l8.7 5.8a13.5 13.5 0 0015.2 0l9.7-6.6 1-.7c2.7-1.9 4.2-4.1 4.2-6.6z"/>
        """
      end,
      fn _color ->
        """
          <path fill="#fff" d="M250 258.3c-33 0-59.9 19.1-59.9 42.7 0 7.6 2.8 14.7 7.7 20.9a53 53 0 007.5 7.4c4.7 3.4 9.5 5 14.2 5 15.2 0 29-15.6 30.5-33.3 2 23.3 25.1 42.7 44.7 28.3 2.6-2.1 5-4.4 7-6.9l.5-.5a33.5 33.5 0 007.6-21c0-23.5-26.8-42.6-59.8-42.6z"/>
          <path fill="#15212a" d="M282.5 299.6c-.8 0-1.5.7-1.5 1.5 0 2-1.1 3.5-3.4 4.8-5.8 3.3-17 3.3-22.7 0-2.3-1.4-3.4-3-3.4-5v-.1l.4-.4 13.8-10.8c2.3-1.8 1-5.6-2-5.6h-27.4c-3 0-4.3 3.8-2 5.6l13.8 10.8.4.3v.2c0 2-1.1 3.6-3.4 5-5.7 3.3-17 3.3-22.7 0-2.3-1.3-3.4-2.9-3.4-4.8 0-.8-.7-1.5-1.5-1.5-.9 0-1.5.7-1.5 1.5 0 3 1.7 5.6 5 7.5 3.2 1.9 8 2.8 12.6 2.8 4.8 0 9.6-1 13-3 1.5-.8 2.6-1.8 3.4-3 .8 1.2 2 2.2 3.4 3 3.4 2 8.2 3 13 3 4.7 0 9.4-1 12.7-2.8 3.2-1.9 5-4.5 5-7.5 0-.8-.7-1.5-1.6-1.5z"/>
        """
      end,
      fn _color ->
        """
          <path fill="#15212a" d="M288.6 308.7a2.8 2.8 0 00-3.5-1.4l-18.5 7c0-.2-.1-.3-.3-.3-6.6-3.8-11.5-11.6-14.8-23.8 9.6 0 17 .7 17-9a18.5 18.5 0 10-37 0c0 9.7 7.5 9 17 9v.3c3.3 12.3 8 20.5 14.7 25-12 4.5-21.4 8.3-19 8.5 0 0 30.7-5.2 39.8-8.7 5.4-2.1 5.4-4.8 4.6-6.6z"/>
        """
      end,
      fn color ->
        """
          <path fill="#fff" d="M250 328v25.9c-8.2.6-16.5 1-25 .4a89 89 0 01-14.1-2c-4.8-1-9.5-2.6-14.1-5a34.6 34.6 0 01-18.4-23.7c-1-4.7-1.2-9.4-1-13.9.3-4.5 1-8.8 2-13a2.7 2.7 0 015.3.6c-.2 8.2.6 16.5 3.6 23.2 1.5 3.3 3.5 6.1 6 8.2 2.5 2 5.3 3.5 8.6 4.4 6.5 1.8 14 1.7 21.6.6 7.6-1 15.3-3 23-5.3.8-.2 1.7-.4 2.5-.4z"/>
          <path fill="#fff" d="M250 328v25.9c8.2.6 16.5 1 25 .4a89 89 0 0014.1-2c4.8-1 9.6-2.6 14.1-5a34.6 34.6 0 0018.4-23.7c1-4.7 1.2-9.4 1-13.9-.3-4.5-1-8.8-2-13a2.7 2.7 0 00-5.3.6c.2 8.2-.6 16.5-3.6 23.2a22.8 22.8 0 01-6 8.2c-2.5 2-5.3 3.5-8.6 4.4-6.5 1.8-14 1.7-21.6.6-7.6-1-15.3-3-23-5.3-.8-.2-1.7-.4-2.5-.4z"/>
          <path fill="#{darken(color, 30)}" d="M292.8 330.6c0 1.2 0 2.3-.2 3.4-2.2 16.6-20.4 24.4-42.6 24.4-22 0-40.3-7.7-42.6-24.2a25.2 25.2 0 01-.2-3.6v-2c1.4-17.2 20-44.2 42.8-44.2 22.9 0 41.6 27.2 42.8 44.5v1.7z"/>
          <circle fill="#15212a" cx="270.6" cy="335.6" r="8.1"/>
          <circle fill="#15212a" cx="229.4" cy="335.6" r="8.1"/>
        """
      end,
      fn color ->
        """
          <path fill="#fff" d="M210.3 362L193 359a3.2 3.2 0 01-2.6-3.4l1.1-18c.1-1.9 2-3.3 3.8-3l22 4c2 .4 3.2 2.5 2.5 4.3l-6 17.1c-.4 1.5-2 2.4-3.6 2.1zM289.8 362L307 359a3.2 3.2 0 002.6-3.4l-1.1-18c-.1-1.9-2-3.3-3.8-3l-22 4c-2 .4-3.2 2.5-2.5 4.3l6 17.1c.4 1.5 2 2.4 3.6 2.1z"/>
          <path fill="#{darken(color, 30)}" d="M275.7 273.1c-9.4 0-18.2-1.5-25.7 2-7.5-3.5-16.3-2-25.7-2-27.9 0-50.5 17.4-50.5 39 0 21.4 22.6 38.8 50.5 38.8 9.4 0 18.2-6.8 25.7-10.2 7.5 3.4 16.3 10.2 25.7 10.2 27.9 0 50.5-17.4 50.5-38.9s-22.6-38.9-50.5-38.9z"/>
          <path fill="#15212a" d="M219.9 307.1c-.9 0-1.7 0-2.6-.2a4 4 0 01.5-8h2.1c2.6 0 4.6-1 5.5-5.8a4 4 0 014.7-3.2 4 4 0 013.2 4.7c-1.5 8-6.3 12.5-13.4 12.5zM281.1 307.1c.9 0 1.7 0 2.6-.2a4 4 0 00-.5-8h-2.1c-2.6 0-4.6-1-5.5-5.8a4 4 0 00-4.7-3.2 4 4 0 00-3.2 4.7c1.5 8 6.3 12.5 13.4 12.5z"/>
        """
      end,
      fn _color ->
        """
          <path fill="#15212a" d="M286 305.4c3-.6 5.7-.6 8.2-.1-5 17.3-18.5 26.5-42 28.8V318c0-8.2 4.9-15.7 12.5-18.6 10-3.8 16.6-11.6 17.3-21.3.5-7.8-5.3-14.8-13.2-15a13.5 13.5 0 00-13.6 11.1c-2.6 1-7.8 1-10.4 0a13.5 13.5 0 00-13.7-11.1c-7.6.2-13.5 7-13 14.6.3 8.1 4.8 15.2 12.5 19.5 1.3.8 2.8 1.5 4.3 2.1a20 20 0 0112.9 18.7v20.4c27.7-1.6 44.5-12 50.3-32 2.3 1 4.5 2.5 6.6 4.6-4-8.2-10.4-9.4-18.7-5.6z"/>
        """
      end,
      fn _color ->
        """
          <path fill="#15212a" d="M249.8 294.6s-16.6-.3-16.6 4.9 11.6 18.9 16.6 18.9 16.7-14 16.7-18.9c0-5-16.7-5-16.7-5z"/>
          <path fill="#15212a" d="M296.2 323l-.1.4a24 24 0 01-3.5 7.6 21.3 21.3 0 01-6 5.6 25 25 0 01-30.3-3.2c-1.8-2-3.1-4.4-3.8-7-.8-2.5-.9-5.2-.6-7.8l.2-1.5-1.5-.2v-.2l-.8.1h-.7v.1l-1.5.2.1 1.5c.4 2.6.3 5.3-.5 7.9-.7 2.5-2 5-3.8 6.9a25 25 0 01-30.3 3.3 21.2 21.2 0 01-6-5.7 24 24 0 01-3.5-7.6l-.1-.5-1 .3.2.4a25 25 0 003.4 8c1.6 2.5 3.7 4.6 6.2 6.3 4.9 3.3 11 4.7 16.8 4.3a25 25 0 0016.1-7.1c2.1-2.2 3.7-4.9 4.6-7.8 1 3 2.6 5.6 4.7 7.8a25 25 0 0016 7c6 .5 12-1 17-4.2a22.6 22.6 0 009.5-14.3l.1-.5-.9-.2z"/>
          <path fill="#15212a" d="M148.9 311.9l.2-2 50.2 6.4-.2 2zM149.9 332.7l49.1-6.2.2 2-49 6.1zM160 357.1l40-21.8.9 1.8-40 21.8zM304.2 316.3l50.2-6.4.2 2-50.2 6.4zM304.2 328.5l.3-2 49 6.2-.2 2zM302.5 337l1-1.7 39.9 21.8-1 1.8z"/>
        """
      end,
      fn _color ->
        """
          <path fill="#15212a" d="M250 278.7c-15.5 0-21.2 4.1-21.2 12.9 0 8.7 21.2 21.8 21.2 21.8s21.2-12.5 21.2-21.8-5.7-12.9-21.2-12.9z"/>
          <path fill="#15212a" d="M319.2 321c-.4-.9-1.4-1.3-2.4-1-21 9-42.8 13.5-65 13.5v-25.8a1.8 1.8 0 10-3.6 0v25.8c-21.3-.4-43-5-65.1-13.4-1-.4-2 0-2.3 1-.4.9 0 2 1 2.3a193.4 193.4 0 0068.7 13.7h1c22.8 0 45.1-4.6 66.7-13.7 1-.4 1.4-1.5 1-2.4z"/>
        """
      end,
      fn _color ->
        """
          <path fill="#15212a" d="M277.6 291.26c0 9.56-12.36 21.7-27.6 21.7s-27.6-12.14-27.6-21.7 12.36-14.83 27.6-14.83 27.6 5.28 27.6 14.83zM219.24 307.93c-4.98-1.74-10.12-3-15.35-3.67a69.16 69.16 0 0 0-15.82-.22c-10.56 1.04-20.83 4.51-30.4 9.27l-.35-.68c9.45-5.11 19.73-9.01 30.53-10.46 5.39-.73 10.87-.85 16.3-.34 5.44.51 10.81 1.63 16.03 3.25l-.94 2.85zM219.98 312.52c-9.35 1.47-18.46 4.57-26.91 8.99-8.47 4.42-16.28 10.1-23.44 16.51l-.36-.39c6.9-6.73 14.53-12.8 22.95-17.67 8.4-4.87 17.62-8.46 27.23-10.4l.53 2.96zM222.41 318.16a45.94 45.94 0 0 0-10.58 6.51c-3.22 2.65-6.07 5.75-8.52 9.17-4.91 6.84-8.2 14.81-10.48 23.01l-.64-.16c1.92-8.34 4.86-16.58 9.61-23.88 2.37-3.64 5.19-7.02 8.45-9.96 3.25-2.94 6.93-5.43 10.87-7.4l1.29 2.71zM232.69 317.9c-6.32 5.69-11.5 12.7-14.8 20.62-3.35 7.91-4.8 16.59-4.95 25.25h-.47c-.27-8.71.76-17.58 3.8-25.89 1.51-4.15 3.5-8.14 5.93-11.86 2.42-3.72 5.27-7.17 8.42-10.31l2.07 2.19z"/>
          <path fill="#15212a" d="M280.76 307.93c4.98-1.74 10.12-3 15.35-3.67a69.16 69.16 0 0 1 15.82-.22c10.56 1.04 20.83 4.51 30.4 9.27l.35-.68c-9.45-5.11-19.73-9.01-30.53-10.46-5.39-.73-10.87-.85-16.3-.34-5.44.51-10.81 1.63-16.03 3.25l.94 2.85zM280.02 312.52c9.35 1.47 18.46 4.57 26.91 8.99 8.47 4.42 16.28 10.1 23.44 16.51l.36-.39c-6.9-6.73-14.53-12.8-22.95-17.67-8.4-4.87-17.62-8.46-27.23-10.4l-.53 2.96zM277.59 318.16a45.94 45.94 0 0 1 10.58 6.51c3.22 2.65 6.07 5.75 8.52 9.17 4.91 6.84 8.2 14.81 10.48 23.01l.64-.16c-1.92-8.34-4.86-16.58-9.61-23.88-2.37-3.64-5.19-7.02-8.45-9.96a48.654 48.654 0 0 0-10.87-7.4l-1.29 2.71zM267.31 317.9c6.32 5.69 11.5 12.7 14.8 20.62 3.35 7.91 4.8 16.59 4.95 25.25h.47c.27-8.71-.76-17.58-3.8-25.89-1.51-4.15-3.5-8.14-5.93-11.86-2.42-3.72-5.27-7.17-8.42-10.31l-2.07 2.19z"/>
        """
      end,
      fn _color ->
        """
          <path fill="#15212a" d="M249.23 293.56c-24.54-7.26-40.9-32.68 1.34-33.81 40.65 1.14 25.14 26.93 1.34 33.82-.87.25-1.81.24-2.68-.01z"/>
          <path fill="#15212a" d="M288.25 294.99c-7.94 7.07-15.74 12.03-23.51 14.78a42.65 42.65 0 0 1-15.01 2.74 41.63 41.63 0 0 1-14.75-2.68c-7.73-2.74-15.47-7.7-23.24-14.88a1.62 1.62 0 0 1-.1-2.31 1.67 1.67 0 0 1 2.35-.1c7.78 7.15 15.41 12.03 23.02 14.58 1.19.4 2.37.74 3.56 1.03a38.47 38.47 0 0 0 18.35 0c1.15-.28 2.3-.6 3.46-.99 7.74-2.54 15.59-7.43 23.65-14.65a1.7 1.7 0 0 1 2.35.13c.59.69.56 1.75-.13 2.35z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{darken(color, 30)}" d="M316.5 341.28c-6.67 6.12-14.33 9.99-21.58 11.43l-.36.24-1.63 1.01c-11.86 7.12-26.8 11.37-43.04 11.37-16.53 0-31.7-4.4-43.66-11.75-.51-.31-1.02-.63-1.51-.96l-.34-.23c-7.05-1.54-14.43-5.36-20.88-11.29-14.57-13.4-18.84-32.48-9.52-42.63a19.02 19.02 0 0 1 10.68-5.72h.01c9.45-1.01 20.45 3.37 32.59 11.61-11.89-11.69-21.25-15.66-29.64-16.7 11.51-17.41 35.06-29.35 62.28-29.35 27.32 0 50.95 12.03 62.42 29.55-8.37 1.04-17.72 5.04-29.57 16.68 12.13-8.23 23.14-12.61 32.58-11.61h.02c4.19.8 7.9 2.68 10.68 5.72 9.31 10.14 5.05 29.22-9.53 42.63z"/>
          <path fill="#15212a" d="M194.37 301.88s18.83 13.68 21.26 20.7c1.87 5.39 2.8 12.87-4.48 16.23-7.27 3.36-12.72 1.91-16.79-3.36-4.11-5.33-10.83-42.37.01-33.57zM305.64 302.06s-18.68 13.37-21.26 20.7c-1.9 5.38-2.8 12.87 4.48 16.23 7.27 3.36 12.05 1.62 16.79-3.36 4.63-4.87 10.82-42.37-.01-33.57zM294.92 352.71l-1.99 1.25c-16.29 3.18-26.04.33-34.81-2.98-5.06-1.92-10.71-1.47-16-.38-9.85 2.02-18.62 5.91-35.88 2.98a73.1 73.1 0 0 1-1.86-1.19c6.3.59 16.16 1.36 21.54 0 8.52-2.16 12.2-7.52 23.98-7.52 11.77 0 11.05 4.08 20.29 7.52 6.02 2.23 17.63 1.16 24.73.32z"/>
        """
      end,
      fn color ->
        """
          <path fill="#{darken(color, 30)}" d="M305.2 329c0 25-24.7 45.2-55.2 45.2S194.8 354 194.8 329c0-14 7.7-26.5 20-34.8 3.6 4.6 9 7.5 14.6 10.4-8.2-6.1-12-11.5-13.6-16.5-.4-1.4-.7-2.7-.9-4.1-1.3-9.8 2.1-18.6 9.4-21.9 8.4-3.8 19.3 1.4 25.7 11.8 6.4-10.4 17.3-15.6 25.7-11.8 8.4 3.8 11.6 15 8.4 26.4v.2c-1.7 4.8-5.6 10-13.5 16 5.6-3 11-6 14.7-10.5a42.5 42.5 0 0 1 20 34.8z"/>
          <path fill="#15212a" d="M243.2 294.8c8-3.7 5-17-2.1-20.8-7.1-3.9-16.9 3-15.5 8.2s12.8 14.8 17.6 12.6zM256.8 294.8c-8-3.7-5-17 2.1-20.8 7.2-3.9 16.9 3 15.5 8.2-1.4 5.2-12.8 14.8-17.6 12.6z"/>
          <path fill="#15212a" d="M294.2 338.9l-.5-.1c-28.5-9.9-57-9.7-84.9 0-.6.1-1 .3-1.4-.3-.3-.6 0-1.1.5-1.4 11.3-5.8 25.7-5.8 35.8-9.3a18 18 0 0 1 11.8-.1c9.8 3.3 26.8 3.5 39 9.5.5.3 1 .8.7 1.4-.2.4-.6.3-1 .3z"/>
        """
      end
    ]
  end

  def patterns do
    [
      fn color ->
        """
          <path fill="#{darken(color, -30)}" d="M156 387.1c-57.8-12.3-96.7-42-96.7-107 0-9.4.8-18.6 2.4-27.6 19.1 3.4 39.3 17 53.6 38.1a105 105 0 015 8.2 73.6 73.6 0 0021 23.8c4.9 3.6 9.5 8.3 13.3 14 12.3 18.2 12.6 40 1.3 50.5z"/>
        """
      end,
      fn color ->
        """
          <ellipse cx="323.8" cy="217.4" fill="#{darken(color, -30)}" rx="52.3" ry="77.6" transform="rotate(-32.5 323.8 217.4)"/>
        """
      end,
      fn color ->
        """
          <path fill="#{darken(color, -30)}" d="M235 161.3c14.4 27.5 0 71-41.1 115.2-31.8 34.1-86.6 16.8-101-10.8s7.5-67.4 48.9-89 78.9-43 93.3-15.4z"/>
        """
      end
    ]
  end

  defp optional(shapes) do
    Enum.map(shapes, fn shape ->
      if Enum.random([0, 1]) == 0, do: shape, else: empty_shape()
    end)
  end

  def create_svg(size, children) do
    """
    <svg
      xmlns='http://www.w3.org/2000/svg'
      version='1.1'
      width='#{size}'
      height='#{size}'
      viewBox='0 0 500 500'
    >
      #{children |> Enum.join("")}
    </svg>
    """
  end

  def create_background(round, color, class) do
    """
    <rect
      width='500'
      height='500'
      rx='#{if round, do: 250, else: 0}'
      fill='#{color}'
      class='#{class}'
    />
    """
  end

  def create_blackout(round) do
    """
    <path
      d='#{if round, do: "M250,0a250,250 0 1,1 0,500", else: "M250,0L500,0L500,500L250,500"}'
      fill='#15212a'
      fill-opacity='0.08'
    />
    """
  end

  def darken(hex, amount) do
    "#" <>
      (hex
       |> Chameleon.convert(Chameleon.RGB)
       |> Map.from_struct()
       |> Map.values()
       |> Enum.map(fn
         x -> clamp(x - amount, 0, 255)
       end)
       |> then(fn [r, g, b] -> Chameleon.RGB.new(r, g, b) end)
       |> Chameleon.convert(Chameleon.Hex)
       |> Map.get(:hex))
  end

  def clamp(value, min, max) do
    min = if min < max, do: min, else: max
    max = if min < max, do: max, else: min

    if value < min do
      min
    else
      if value > max, do: max, else: value
    end
  end

  defp seed_randomiser(seed) do
    # let's seed the random algorithm
    :rand.seed(:exsplus, seed |> to_charlist() |> Enum.take(3) |> List.to_tuple())
  end
end
