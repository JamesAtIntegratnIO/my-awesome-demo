package main

import (
    "log"
    "net/http"
    "os"
    
    "github.com/gin-gonic/gin"
    "github.com/gin-contrib/cors"
    
    
    "github.com/redis/go-redis/v9"
    "github.com/sirupsen/logrus"
)

var logger = logrus.New()




var rdb *redis.Client


func init() {
    // Configure logger
    logger.SetFormatter(&logrus.TextFormatter{
        FullTimestamp: true,
    })
    
    // Set log level from environment
    level := os.Getenv("LOG_LEVEL")
    if level == "" {
        level = "info"
    }
    
    if logLevel, err := logrus.ParseLevel(level); err == nil {
        logger.SetLevel(logLevel)
    }
}

func main() {
    logger.Info("Starting my-awesome-demo server")
    
    
    
    
    // Initialize Redis
    initRedis()
    
    
    // Initialize router
    r := gin.Default()
    
    
    // Add CORS middleware
    r.Use(cors.Default())
    
    
    // Routes
    r.GET("/", func(c *gin.Context) {
        logger.Info("Root endpoint accessed")
        c.JSON(http.StatusOK, gin.H{
            "message": "Welcome to my-awesome-demo",
            "version": "1.0.0",
        })
    })
    
    r.GET("/health", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "status": "ok",
            "service": "my-awesome-demo",
        })
    })
    
    // Start server
    port := os.Getenv("PORT")
    if port == "" {
        port = "5173"
    }
    
    logger.Infof("Server starting on port %s", port)
    if err := r.Run(":" + port); err != nil {
        logger.Fatalf("Server failed to start: %v", err)
    }
}




func initRedis() {
    logger.Info("Initializing Redis connection")
    rdb = redis.NewClient(&redis.Options{
        Addr:     os.Getenv("REDIS_ADDR"),
        Password: os.Getenv("REDIS_PASSWORD"),
        DB:       0,
    })
    
    logger.Info("Redis connected successfully")
}

