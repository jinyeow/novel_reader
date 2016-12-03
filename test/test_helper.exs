# use @tag :pending or @tag :skip to skip those tests
ExUnit.configure exclude: [:pending, :skip]

# This line is needed for 'ex_unit_notifier' for desktop notifications
ExUnit.configure formatters: [ExUnit.CLIFormatter, ExUnitNotifier]

ExUnit.start()
