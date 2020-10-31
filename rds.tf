module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "week5db"

  engine            = "mariadb"
  engine_version    = "10.4.8"
  instance_class    = "db.t2.micro"
  allocated_storage = 5

  name     = "week5db"
  username = "admin"
  password = "admin*123"
  port     = "3306"
  multi_az = "true"
  iam_database_authentication_enabled = false

  vpc_security_group_ids = [aws_security_group.My_RDS_Security.id]
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "30"
  monitoring_role_name = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "Devops"
    Environment = "Free tier"
  }

  # DB subnet group
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet2.id]
  # DB parameter group
  family = "mariadb10.4"

  # DB option group
  major_engine_version = "10.4"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "week5db"

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name = "character_set_client"
      value = "utf8"
    },
    {
      name = "character_set_server"
      value = "utf8"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}